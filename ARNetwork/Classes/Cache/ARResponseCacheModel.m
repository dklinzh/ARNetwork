//
//  ARResponseCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARResponseCacheModel.h"
#import "ARDataCacheManager.h"
#import "NSString+ARSHA1.h"

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
- (instancetype)initAndAddDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params responseObject:(id)responseObject {
    if (self = [self init]) {
        if (!self.isInvalidated && responseObject) {
            NSURL *url = [NSURL URLWithString:urlStr];
            self.arPrimaryKey = [[NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description] ar_SHA1];
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
