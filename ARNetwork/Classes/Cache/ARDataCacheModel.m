//
//  ARDataCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "ARDataCacheManager.h"
#import "NSObject+ARInspect.h"
#import "NSString+ARSHA1.h"

@implementation ARDataCacheModel

#pragma mark -

+ (instancetype)ar_createInDefaultRealmWithValue:(id)value {
    return [self createInRealm:[ARDataCacheManager defaultRealm] withValue:value];
}

+ (instancetype)ar_createOrUpdateInDefaultRealmWithValue:(id)value {
    return [self createOrUpdateInRealm:[ARDataCacheManager defaultRealm] withValue:value];
}

+ (RLMResults *)ar_allObjects {
    return [self allObjectsInRealm:[ARDataCacheManager defaultRealm]];
}

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat, ... {
    va_list args;
    va_start(args, predicateFormat);
    RLMResults *results = [self ar_objectsWhere:predicateFormat args:args];
    va_end(args);
    return results;
}

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat args:(va_list)args {
    return [self objectsInRealm:[ARDataCacheManager defaultRealm] where:predicateFormat args:args];
}

+ (RLMResults *)ar_objectsWithPredicate:(NSPredicate *)predicate {
    return [self objectsInRealm:[ARDataCacheManager defaultRealm] withPredicate:predicate];
}

+ (instancetype)ar_objectForPrimaryKey:(id)primaryKey {
    return [self objectInRealm:[ARDataCacheManager defaultRealm] forPrimaryKey:primaryKey];
}

#pragma mark -
+ (NSTimeInterval)expiredInterval {
    return 0;
}

+ (NSArray *)equalValueSkippedProperties {
    return nil;
}

+ (instancetype)dataCache {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    return results.lastObject;
}

+ (instancetype)dataCache:(NSUInteger)index {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    if (index >= results.count) {
        return nil;
    }
    return results[index];
}

+ (NSUInteger)dataCacheCount {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    return results.count;
}

+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!urlStr) {
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *arPrimaryKey = [[NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description] ar_SHA1];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"arPrimaryKey = %@", arPrimaryKey];
    RLMResults<__kindof ARDataCacheModel *> *caches = [self ar_objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}

- (instancetype)initDataCacheWithData:(NSDictionary *)data {
    if (self = [self init]) {
        [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                if ([value isKindOfClass:NSDictionary.class]) {
                    id obj = [[self ar_classOfPropertyNamed:key] alloc];
                    if ([obj isKindOfClass:ARDataCacheModel.class]) {
                        [self setValue:[obj initDataCacheWithData:value] forKey:key];
                    }
                } else if ([value isKindOfClass:NSArray.class]) {
                    id obj = [self valueForKey:key];
                    if ([obj isKindOfClass:RLMArray.class]) {
                        RLMArray *objs = (RLMArray *)obj;
                        Class clazz = NSClassFromString(objs.objectClassName);
                        if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                            NSArray *values = (NSArray *)value;
                            for (NSDictionary *item in values) {
                                [objs addObject:[[clazz alloc] initDataCacheWithData:item]];
                            }
                        }
                    }
                } else {
                    [self setValue:value forKey:key];
                }
            }
        }];
        [self setValueForExtraProperties];
    }
    return self;
}

- (void)addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!self.realm) {
        NSURL *url = [NSURL URLWithString:urlStr];
        self.arPrimaryKey = [[NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description] ar_SHA1];
        self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[self.class expiredInterval] > 0 ? : [ARDataCacheManager sharedInstance].expiredInterval];
        RLMRealm *realm = [ARDataCacheManager defaultRealm];
        [realm transactionWithBlock:^{
            if ([self.class primaryKey]) {
                [realm addOrUpdateObject:self];
            } else {
                [realm addObject:self];
            }
        }];
    }
}

- (void)updateDataCacheWithData:(NSDictionary *)data {
    if (!self.isInvalidated) {
        [[ARDataCacheManager defaultRealm] transactionWithBlock:^{
            [self updateDataCacheWithDataPartInTransaction:data];
            self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[self.class expiredInterval] > 0 ? : [ARDataCacheManager sharedInstance].expiredInterval];
        }];
    }
}

- (void)updateDataCacheWithDataPartInTransaction:(NSDictionary *)data {
    NSArray *equalValueSkippedProperties = [self.class equalValueSkippedProperties];
    NSString *primaryKey = [self.class primaryKey];
    [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if ([primaryKey isEqualToString:key]) {
            return;
        }
        
        if ([self respondsToSelector:NSSelectorFromString(key)]) {
            if ([equalValueSkippedProperties containsObject:key]) {
                id value = [self valueForKey:key];
                if ([value isEqual:data[key]]) {
                    return;
                }
            }
            
            if ([value isKindOfClass:NSDictionary.class]) {
                Class clazz = [self ar_classOfPropertyNamed:key];
                if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                    id obj = [self valueForKey:key];
                    if (obj) {
                        [obj updateDataCacheWithDataPartInTransaction:value];
                    } else {
                        [self setValue:[[clazz alloc] initDataCacheWithData:value] forKey:key];
                    }
                }
            } else if ([value isKindOfClass:NSArray.class]) {
                id obj = [self valueForKey:key];
                if ([obj isKindOfClass:RLMArray.class]) {
                    RLMArray *objs = (RLMArray *)obj;
                    Class clazz = NSClassFromString(objs.objectClassName);
                    if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                        NSArray *values = (NSArray *)value;
                        NSString *primaryKey = [clazz primaryKey];
                        if (primaryKey) {
                            NSMutableDictionary *map = [NSMutableDictionary dictionary];
                            for (id item in objs) {
                                [map setObject:item forKey:[item valueForKey:primaryKey]];
                            }
                            for (NSDictionary *item in values) {
                                id primaryValue = [item valueForKey:primaryKey];
                                id primaryObj = [map objectForKey:primaryValue];
                                if (primaryObj) {
                                    [primaryObj updateDataCacheWithDataPartInTransaction:item];
                                    [map removeObjectForKey:primaryValue];
                                } else {
                                    [objs addObject:[[clazz alloc] initDataCacheWithData:item]];
                                }
                            }
                            [[ARDataCacheManager defaultRealm] deleteObjects:map.allValues];
                        } else {
                            [objs removeAllObjects];
                            for (NSDictionary *item in values) {
                                [objs addObject:[[clazz alloc] initDataCacheWithData:item]];
                            }
                        }
                    }
                }
            } else {
                [self setValue:value forKey:key];
            }
        }
    }];
    [self setValueForExtraProperties];
}

- (void)setValueForExtraProperties {
    // Set value for any additional properties on the subclass of 'ARDataCacheModel'
}
@end

