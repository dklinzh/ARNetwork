//
//  ARDataCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "_NSObject+ARInspect.h"
#import "_ARDataCacheManager_Private.h"
#import "_ARDataCacheModel_Private.h"

@implementation ARDataCacheModel

+ (RLMRealm *)ar_defaultRealm {
    return [ARDataCacheManager _realmWithModelClass:self.class];
}

+ (instancetype)ar_createInDefaultRealmWithValue:(id)value {
    return [self createInRealm:[self ar_defaultRealm] withValue:value];
}

+ (instancetype)ar_createOrUpdateInDefaultRealmWithValue:(id)value {
    return [self createOrUpdateInRealm:[self ar_defaultRealm] withValue:value];
}

+ (RLMResults *)ar_allObjects {
    return [self allObjectsInRealm:[self ar_defaultRealm]];
}

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat, ... {
    va_list args;
    va_start(args, predicateFormat);
    RLMResults *results = [self ar_objectsWhere:predicateFormat args:args];
    va_end(args);
    return results;
}

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat args:(va_list)args {
    return [self objectsInRealm:[self ar_defaultRealm] where:predicateFormat args:args];
}

+ (RLMResults *)ar_objectsWithPredicate:(NSPredicate *)predicate {
    return [self objectsInRealm:[self ar_defaultRealm] withPredicate:predicate];
}

+ (instancetype)ar_objectForPrimaryKey:(id)primaryKey {
    return [self objectInRealm:[self ar_defaultRealm] forPrimaryKey:primaryKey];
}

#pragma mark -
+ (NSTimeInterval)expiredInterval {
    return [ARDataCacheManager _managerWithModelClass:self.class].expiredInterval;
}

+ (NSArray *)equalValueSkippedProperties {
    return nil;
}

+ (instancetype)dataCache {
    return [self dataCache:0];
}

+ (instancetype)dataCache:(NSUInteger)index {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    if (index + 1 > results.count) {
        return nil;
    }
    return results[index];
}

+ (NSUInteger)dataCacheCount {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    return results.count;
}

+ (instancetype)_dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!urlStr) {
        return nil;
    }
    
    NSString *arPrimaryKey = ar_cacheKey(urlStr, params);
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"_AR_CACHE_KEY = %@", arPrimaryKey];
    RLMResults<__kindof ARDataCacheModel *> *caches = [self ar_objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}

- (instancetype)initDataCache:(NSDictionary *)data {
    if (self = [self init]) {
        [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                if ([value isKindOfClass:NSDictionary.class]) {
                    id obj = [[self ar_classOfPropertyNamed:key] alloc];
                    if ([obj isKindOfClass:ARDataCacheModel.class]) {
                        [self setValue:[obj initDataCache:value] forKey:key];
                    }
                } else if ([value isKindOfClass:NSArray.class]) {
                    id obj = [self valueForKey:key];
                    if ([obj isKindOfClass:RLMArray.class]) {
                        RLMArray *objs = (RLMArray *)obj;
                        Class clazz = NSClassFromString(objs.objectClassName);
                        if ([clazz isSubclassOfClass:ARWrapedString.class]) {
                            NSArray *values = (NSArray *)value;
                            for (id item in values) {
                                if ([item isKindOfClass:NSString.class]) {
                                    [objs addObject:[[ARWrapedString alloc] initWithString:item]];
                                }
                            }
                        } else if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                            NSArray *values = (NSArray *)value;
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    [objs addObject:[[clazz alloc] initDataCache:item]];
                                }
                            }
                        }
                    }
                } else {
                    [self setValue:value forKey:key];
                }
            }
        }];
        
        if ([self respondsToSelector:@selector(setValueForExtraProperties)]) {
            [self setValueForExtraProperties];
        }
    }
    return self;
}

- (void)_addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!self.realm) {
        self._AR_CACHE_KEY = ar_cacheKey(urlStr, params);
        self._AR_EXPIRED_TIME = [NSDate dateWithTimeIntervalSinceNow:[self.class expiredInterval]];
        RLMRealm *realm = [self.class ar_defaultRealm];
        [realm transactionWithBlock:^{
            if ([self.class primaryKey]) {
                [realm addOrUpdateObject:self];
            } else {
                [realm addObject:self];
            }
        }];
    }
}

- (void)updateDataCache:(NSDictionary *)data {
    if (!self.isInvalidated) {
        [[self.class ar_defaultRealm] transactionWithBlock:^{
            [self updateDataCacheWithDataPartInTransaction:data];
            self._AR_EXPIRED_TIME = [NSDate dateWithTimeIntervalSinceNow:[self.class expiredInterval]];
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
                        [self setValue:[[clazz alloc] initDataCache:value] forKey:key];
                    }
                }
            } else if ([value isKindOfClass:NSArray.class]) {
                id obj = [self valueForKey:key];
                if ([obj isKindOfClass:RLMArray.class]) {
                    RLMArray *objs = (RLMArray *)obj;
                    Class clazz = NSClassFromString(objs.objectClassName);
                    if ([clazz isSubclassOfClass:ARWrapedString.class]) {
                        [objs removeAllObjects];
                        NSArray *values = (NSArray *)value;
                        for (id item in values) {
                            if ([item isKindOfClass:NSString.class]) {
                                [objs addObject:[[ARWrapedString alloc] initWithString:item]];
                            }
                        }
                    } else if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                        NSArray *values = (NSArray *)value;
                        NSString *primaryKey = [clazz primaryKey];
                        if (primaryKey) {
                            NSMutableDictionary *map = [NSMutableDictionary dictionary];
                            for (id item in objs) {
                                [map setObject:item forKey:[item valueForKey:primaryKey]];
                            }
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    id primaryValue = [item valueForKey:primaryKey];
                                    id primaryObj = [map objectForKey:primaryValue];
                                    if (primaryObj) {
                                        [primaryObj updateDataCacheWithDataPartInTransaction:item];
                                        [map removeObjectForKey:primaryValue];
                                    } else {
                                        [objs addObject:[[clazz alloc] initDataCache:item]];
                                    }
                                }
                            }
                            [[self.class ar_defaultRealm] deleteObjects:map.allValues];
                        } else {
                            [objs removeAllObjects];
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    [objs addObject:[[clazz alloc] initDataCache:item]];
                                }
                            }
                        }
                    }
                }
            } else {
                [self setValue:value forKey:key];
            }
        }
    }];
    
    if ([self respondsToSelector:@selector(setValueForExtraProperties)]) {
        [self setValueForExtraProperties];
    }
}

@end

@implementation ARDataCacheModel (ThreadSafe)

- (instancetype)ar_resolveThreadSafeReference:(RLMThreadSafeReference *)reference {
    return [[self.class ar_defaultRealm] resolveThreadSafeReference:reference];
}

- (instancetype)ar_resolveMainThreadSafeReference {
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    __block RLMThreadSafeReference *reference = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        reference = [RLMThreadSafeReference referenceWithThreadConfined:self];
        [lock unlock];
    });
    [lock lock];
    [lock unlock];
    return [self ar_resolveThreadSafeReference:reference];
}

@end

@implementation ARWrapedString

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        self.value = string;
    }
    return self;
}

@end
