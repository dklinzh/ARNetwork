//
//  ARHTTPManager+Cache.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <ARNetwork/ARNetwork.h>

typedef NS_ENUM(NSInteger, ARDataCache) {
    ARDataCacheNone = 0,
    ARDataCacheOnlyLoad = 1,
    ARDataCacheOnlyUpdate = 1 << 1,
    ARDataCacheLoadAndUpdate = ARDataCacheOnlyLoad | ARDataCacheOnlyUpdate,
};

typedef NS_ENUM(NSInteger, ARCacheError) {
    ARCacheErrorNone = -1000, // Have no cache in local.
    ARCacheErrorSource = -1001, // Format of data source is wrong.
    ARCacheErrorModel = -1002, // Format of class model is wrong.
};

typedef void(^ARCacheResponseSuccess)(id data, NSString *msg, BOOL isCached);
typedef void(^ARCacheResponseFailure)(NSInteger code, NSString *msg);

@interface ARHTTPManager (Cache)
+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure;
@end
