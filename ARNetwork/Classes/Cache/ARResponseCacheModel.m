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
            self.arPrimaryKey = [ARDataCacheManager ar_primaryKeyWithUrl:urlStr params:params];
            self.arResponseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager sharedInstance].expiredInterval];
            RLMRealm *realm = [ARDataCacheManager defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject:self];
            }];
        }
    }
    return self;
}

- (void)updateDataCacheWithResponseObject:(id)responseObject {
    if (!self.isInvalidated) {
        [[ARDataCacheManager defaultRealm] transactionWithBlock:^{
            self.arResponseData = responseObject ? [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] : nil;
            self.arExpiredTime = [NSDate dateWithTimeIntervalSinceNow:[ARDataCacheManager sharedInstance].expiredInterval];
        }];
    }
}

- (id)responseObject {
    if (!self.arResponseData) {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:self.arResponseData options:NSJSONReadingMutableContainers error:nil];
}
@end
