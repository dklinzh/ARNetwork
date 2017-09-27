//
//  ARHTTPManager+Cache.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"
#import "ARDataCache.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ARResponseCacheSuccess)(id data, NSString * _Nullable msg, BOOL isCached);
typedef void(^ARResponseCacheFailure)(NSInteger code, NSString * _Nullable msg);

@interface ARHTTPManager (Cache)
+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(nullable NSDictionary *)params dataCache:(ARCacheType)cacheType success:(nullable ARResponseCacheSuccess)success failure:(nullable ARResponseCacheFailure)failure;
@end

NS_ASSUME_NONNULL_END
