//
//  _ARDataCacheModel_Private.h
//  ARNetwork
//
//  Created by Daniel Lin on 26/09/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "_NSString+ARSHA1.h"

@interface ARDataCacheModel ()
/**
 The primary key for a specific cache data with the kind of class `ARDataCacheModel`. (Read only)
 */
@property NSString * _AR_CACHE_KEY;

/**
 The modified date of a specific cache data with the kind of class `ARDataCacheModel`. (Read only)
 */
@property NSDate * _AR_DATE_MODIFIED;

/**
 The expired date for a specific cache data with the kind of class `ARDataCacheModel`. (Read only)
 */
@property NSDate * _AR_DATE_EXPIRED;

+ (instancetype)_dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;

- (void)_addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;

@end

static inline NSString * ar_cacheKey(NSString *urlStr, NSDictionary *params) {
    return ar_sessionTaskKey(urlStr, params);
}
