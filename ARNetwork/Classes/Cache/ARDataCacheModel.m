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

@implementation ARDataCacheModel

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

#pragma mark -
+ (NSArray *)valueUpdatedProperties {
    return nil;
}

+ (instancetype)dataCache {
    return [self dataCache:0];
}

+ (instancetype)dataCache:(NSUInteger)index {
    RLMResults<__kindof ARDataCacheModel *> *results = [self allObjects];
    if (index >= results.count) {
        return nil;
    }
    return results[index];
}

+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!urlStr) {
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *arPrimaryKey = [NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"arPrimaryKey = %@", arPrimaryKey];
    RLMResults<__kindof ARDataCacheModel *> *caches = [self.class objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}

- (instancetype)initDataCacheWithData:(NSDictionary *)data {
    if (self = [self init]) {
        for (NSString *key in data.allKeys) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                id value = data[key];
                if ([value isKindOfClass:NSDictionary.class]) {
                    id subModel = [[self ar_classOfPropertyNamed:key] alloc];
                    if ([subModel isKindOfClass:ARDataCacheModel.class]) {
                        [self setValue:[subModel initDataCacheWithData:value] forKey:key];
                    }
                } else if ([value isKindOfClass:NSArray.class]) {
                    id rlm = [self valueForKey:key];
                    if ([rlm isKindOfClass:RLMArray.class]) {
                        RLMArray *rlms = (RLMArray *)rlm;
                        Class subClass = NSClassFromString(rlms.objectClassName);
                        if ([subClass isSubclassOfClass:ARDataCacheModel.class]) {
                            NSArray *values = (NSArray *)value;
                            for (NSDictionary *item in values) {
                                [rlms addObject:[[subClass alloc] initDataCacheWithData:item]];
                            }
                        }
                    }
                } else {
                    [self setValue:value forKey:key];
                }
            }
        }
        [self setValueForExtraProperties];
    }
    return self;
}

- (void)addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!self.realm) {
        NSURL *url = [NSURL URLWithString:urlStr];
        self.arPrimaryKey = [NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description];
        self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager sharedInstance].expiredInterval];
        RLMRealm *realm = [RLMRealm defaultRealm];
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
        NSArray *valueUpdatedProperties = [self.class valueUpdatedProperties];
        NSString *primaryKey = [self.class primaryKey];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager sharedInstance].expiredInterval];
            for (NSString *key in data.allKeys) {
                if ([primaryKey isEqualToString:key]) {
                    continue;
                }
                
                if ([self respondsToSelector:NSSelectorFromString(key)]) {
                    if ([valueUpdatedProperties containsObject:key]) {
                        id value = [self valueForKey:key];
                        if (![value isEqual:data[key]]) {
                            
                        }
                    }
                    [self setValue:data[key] forKey:key];
                }
            }
            [self setValueForExtraProperties];
        }];
    }
}

- (void)setValueForExtraProperties {
    
}
@end

