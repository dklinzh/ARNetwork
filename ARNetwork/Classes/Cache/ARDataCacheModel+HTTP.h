//
//  ARDataCacheModel+HTTP.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "ARDataCache.h"

typedef void(^ARDataCacheSuccess)(__kindof ARDataCacheModel *data, NSString *msg, BOOL isCached);
typedef void(^ARDataCacheFailure)(NSInteger code, NSString *msg);

@interface ARDataCacheModel (HTTP)

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure;
@end
