//
//  ARDataCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "ARDataCacheManager.h"

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

+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!urlStr) {
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"arHost = %@ AND arPath = %@ AND arParams = %@", url.host, url.path, params.description];
    RLMResults<__kindof ARDataCacheModel *> *caches = [self.class objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}

- (instancetype)initDataCacheWithData:(NSDictionary *)data {
    if (self = [self init]) {
        for (NSString *key in data.allKeys) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                [self setValue:data[key] forKey:key];
            }
        }
        [self setValueForExtraProperties];
    }
    return self;
}

- (void)addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!self.isInvalidated) {
        if (urlStr) {
            NSURL *url = [NSURL URLWithString:urlStr];
            self.arHost = url.host;
            self.arPath = url.path;
        }
        self.arParams = params.description;
        self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager sharedInstance].expiredInterval];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] addObject:self];
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
