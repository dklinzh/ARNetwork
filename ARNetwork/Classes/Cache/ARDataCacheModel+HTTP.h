//
//  ARDataCacheModel+HTTP.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "ARDataCache.h"
#import "ARHTTPOperation.h"

@class ARHTTPManager;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ARDataCacheSuccess)(__kindof ARDataCacheModel *data, NSString * _Nullable msg, BOOL isCached);
typedef ARHTTPResponseFailure ARDataCacheFailure;

@interface ARDataCacheModel (HTTP)
    
+ (ARHTTPManager *)httpManager;

+ (nullable NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (nullable NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (nullable NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (nullable NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (nullable NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;
@end

NS_ASSUME_NONNULL_END
