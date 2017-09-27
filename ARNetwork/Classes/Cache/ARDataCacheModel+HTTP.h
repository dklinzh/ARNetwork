//
//  ARDataCacheModel+HTTP.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "ARDataCache.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ARDataCacheSuccess)(__kindof ARDataCacheModel *data, NSString * _Nullable msg, BOOL isCached);
typedef void(^ARDataCacheFailure)(NSInteger code, NSString * _Nullable msg);

@interface ARDataCacheModel (HTTP)

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARDataCacheSuccess)success failure:(nullable ARDataCacheFailure)failure;
@end

NS_ASSUME_NONNULL_END
