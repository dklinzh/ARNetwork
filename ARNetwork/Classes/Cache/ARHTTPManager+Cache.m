//
//  ARHTTPManager+Cache.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager+Cache.h"
#import "ARResponseCacheModel.h"

@implementation ARHTTPManager (Cache)

#pragma mark - HTTP
+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] getURL:urlStr params:params dataCache:cache success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    ARResponseCacheModel *oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self getURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] postURL:urlStr params:params dataCache:cache success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    ARResponseCacheModel *oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self postURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] putURL:urlStr params:params dataCache:cache success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    ARResponseCacheModel *oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self putURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] patchURL:urlStr params:params dataCache:cache success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    ARResponseCacheModel *oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self patchURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] deleteURL:urlStr params:params dataCache:cache success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    ARResponseCacheModel *oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self deleteURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

#pragma mark - Private
- (ARResponseCacheModel *)oldDataCache:(ARDataCache *)cache url:(NSString *)urlStr params:(NSDictionary *)params success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    ARResponseCacheModel *oldData;
    if (*cache & (ARDataCacheOnlyLoad | ARDataCacheUpdateIfNeeded)) {
        oldData = [ARResponseCacheModel dataCacheWithUrl:urlStr params:params];
        if (oldData) {
            ARLogDebug(@"Cache<%@>: %@", NSStringFromClass(self.class), oldData);
            
            if ((*cache & ARDataCacheOnlyLoad) && success) {
                success(oldData.responseObject, nil, YES);
            }
            if ((*cache & ARDataCacheUpdateIfNeeded) && (oldData.arExpiredTime.timeIntervalSinceNow > 0)) {
                *cache = ARDataCacheOnlyLoad;
            }
        } else {
            ARLogWarn(@"Cache<%@>: %d, %@", NSStringFromClass(self.class), ARCacheErrorNone,  @"Have no cache in local.");
            
            if (*cache == ARDataCacheOnlyLoad) {
                *cache |= ARDataCacheOnlyUpdate;
            }
        }
    }
    return oldData;
}

- (void)newDataCache:(ARDataCache)cache url:(NSString *)urlStr params:(NSDictionary *)params oldData:(ARResponseCacheModel *)oldData dataSource:(id)data msg:(NSString *)msg success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    if (cache & (ARDataCacheOnlyUpdate | ARDataCacheUpdateIfNeeded)) {
        if (oldData) {
            [oldData updateDataCacheWithResponseObject:data];
            if (success) {
                success(data, msg, NO);
            }
        } else {
            [[ARResponseCacheModel alloc] initAndAddDataCacheWithUrl:urlStr params:params responseObject:data];
            if (success) {
                success(data, msg, NO);
            }
        }
    } else {
        if (success) {
            success(data, msg, NO);
        }
    }
}
@end
