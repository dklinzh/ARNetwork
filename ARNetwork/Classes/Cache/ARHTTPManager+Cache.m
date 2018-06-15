//
//  ARHTTPManager+Cache.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager+Cache.h"
#import "_ARResponseCacheModel.h"
#import "_ARDataCacheModel_Private.h"

@implementation ARHTTPManager (Cache)

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self manager] getURL:urlStr params:params dataCache:cacheType success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    _ARResponseCacheModel *oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self getURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self manager] postURL:urlStr params:params dataCache:cacheType success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    _ARResponseCacheModel *oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self postURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self manager] putURL:urlStr params:params dataCache:cacheType success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    _ARResponseCacheModel *oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self putURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self manager] patchURL:urlStr params:params dataCache:cacheType success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    _ARResponseCacheModel *oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self patchURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    NSURLSessionDataTask *task = [[self manager] deleteURL:urlStr params:params dataCache:cacheType success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    _ARResponseCacheModel *oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self deleteURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

#pragma mark - Private

- (_ARResponseCacheModel *)oldDataCache:(ARCacheType *)cacheType url:(NSString *)urlStr params:(NSDictionary *)params success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    _ARResponseCacheModel *oldData;
    if (*cacheType & (ARCacheTypeOnlyLoad | ARCacheTypeUpdateIfNeeded)) {
        oldData = [_ARResponseCacheModel _dataCacheWithUrl:urlStr params:params];
        if (oldData) {
            ARLogDebug(@"Cache<%@>: %@", NSStringFromClass(self.class), oldData.responseObject);
            
            if ((*cacheType & ARCacheTypeOnlyLoad) && success) {
                success(oldData.responseObject, nil, YES);
            }
            if ((*cacheType & ARCacheTypeUpdateIfNeeded) && (oldData._AR_DATE_MODIFIED.timeIntervalSinceNow <= 0) && (oldData._AR_DATE_EXPIRED.timeIntervalSinceNow > 0)) {
                *cacheType = ARCacheTypeOnlyLoad;
            }
        } else {
            ARLogVerbose(@"Cache<%@>: %ld, %@", NSStringFromClass(self.class), (long)ARCacheErrorNone,  @"Have no cache in local.");
            
            if (*cacheType == ARCacheTypeOnlyLoad) {
                *cacheType |= ARCacheTypeOnlyUpdate;
            }
        }
    }
    return oldData;
}

- (void)newDataCache:(ARCacheType)cacheType url:(NSString *)urlStr params:(NSDictionary *)params oldData:(_ARResponseCacheModel *)oldData dataSource:(id)data msg:(NSString *)msg success:(ARResponseCacheSuccess)success failure:(ARResponseCacheFailure)failure {
    if (cacheType & (ARCacheTypeOnlyUpdate | ARCacheTypeUpdateIfNeeded)) {
        if (oldData) {
            [oldData updateDataCacheWithResponseObject:data];
            if (success) {
                success(data, msg, NO);
            }
        } else {
            __attribute__((unused))
            id unused = [[_ARResponseCacheModel alloc] initAndAddDataCacheWithUrl:urlStr params:params responseObject:data];
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
