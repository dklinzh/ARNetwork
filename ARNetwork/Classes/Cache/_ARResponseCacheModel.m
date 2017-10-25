//
//  _ARResponseCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "_ARResponseCacheModel.h"
#import "_ARDataCacheModel_Private.h"
#import "_ARDataCacheManager_Private.h"

@implementation _ARResponseCacheModel

- (instancetype)initAndAddDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params responseObject:(id)responseObject {
    if (self = [self init]) {
        if (!self.isInvalidated && responseObject) {
            self._AR_CACHE_KEY = ar_cacheKey(urlStr, params);
            self._AR_RESPONSE_DATA = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            self._AR_DATE_MODIFIED = [NSDate date];
            self._AR_DATE_EXPIRED = [NSDate dateWithTimeInterval:[ARDataCacheManager _managerWithModelClass:self.class].expiredInterval sinceDate:self._AR_DATE_MODIFIED];
            RLMRealm *realm = [ARDataCacheManager _realmWithModelClass:self.class];
            [realm transactionWithBlock:^{
                [realm addObject:self];
            }];
        }
    }
    return self;
}

- (void)updateDataCacheWithResponseObject:(id)responseObject {
    if (!self.isInvalidated) {
        [[ARDataCacheManager _realmWithModelClass:self.class] transactionWithBlock:^{
            self._AR_RESPONSE_DATA = responseObject ? [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] : nil;
            self._AR_DATE_MODIFIED = [NSDate date];
            self._AR_DATE_EXPIRED = [NSDate dateWithTimeInterval:[ARDataCacheManager _managerWithModelClass:self.class].expiredInterval sinceDate:self._AR_DATE_MODIFIED];
        }];
    }
}

- (id)responseObject {
    if (!self._AR_RESPONSE_DATA) {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:self._AR_RESPONSE_DATA options:NSJSONReadingMutableContainers error:nil];
}
@end
