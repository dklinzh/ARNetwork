//
//  ARHTTPManager+Cache.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"
#import "ARDataCache.h"

typedef void(^ARResponseCacheSuccess)(id data, NSString *msg, BOOL isCached);
typedef void(^ARResponseCacheFailure)(NSInteger code, NSString *msg);

@interface ARHTTPManager (Cache)
+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure;
@end
