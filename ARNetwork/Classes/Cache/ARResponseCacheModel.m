//
//  ARResponseCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARResponseCacheModel.h"
#import "ARDataCacheManager.h"

@interface ARDataCacheManager ()
+ (NSString *)ar_primaryKeyWithUrl:(NSString *)urlStr params:(NSDictionary *)params;
+ (RLMRealm *)ar_realmWithModelClass:(Class)clazz;
+ (instancetype)ar_managerWithModelClass:(Class)clazz;
@end

@interface ARDataCacheModel ()
+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;
@end

@implementation ARResponseCacheModel

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
+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    return [super dataCacheWithUrl:urlStr params:params];
}

- (instancetype)initAndAddDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params responseObject:(id)responseObject {
    if (self = [self init]) {
        if (!self.isInvalidated && responseObject) {
            self._arPrimaryKey = [ARDataCacheManager ar_primaryKeyWithUrl:urlStr params:params];
            self._arResponseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            self._arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager ar_managerWithModelClass:self.class].expiredInterval];
            RLMRealm *realm = [ARDataCacheManager ar_realmWithModelClass:self.class];
            [realm transactionWithBlock:^{
                [realm addObject:self];
            }];
        }
    }
    return self;
}

- (void)updateDataCacheWithResponseObject:(id)responseObject {
    if (!self.isInvalidated) {
        [[ARDataCacheManager ar_realmWithModelClass:self.class] transactionWithBlock:^{
            self._arResponseData = responseObject ? [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] : nil;
            self._arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager ar_managerWithModelClass:self.class].expiredInterval];
        }];
    }
}

- (id)responseObject {
    if (!self._arResponseData) {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:self._arResponseData options:NSJSONReadingMutableContainers error:nil];
}
@end
