//
//  ARDataCacheModel+HTTP.m
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel+HTTP.h"
#import "ARHTTPManager.h"
#import "_ARDataCacheManager_Private.h"
#import "_ARDataCacheModel_Private.h"
#import "RLMObject+ARCopying.h"

@implementation ARDataCacheModel (HTTP)

+ (ARDataCacheManager *)cacheManager {
    return [ARDataCacheManager _managerWithModelClass:self];
}

+ (ARHTTPManager *)httpManager {
    return [self cacheManager].httpManager;
}

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    ARHTTPManager *httpManager = [self httpManager];
    NSString *cacheKey = [httpManager.operation taskKeyForRequestURL:urlStr params:params];
    id oldData = [self oldDataCache:&cacheType forKey:cacheKey success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [httpManager getURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType forKey:cacheKey oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    ARHTTPManager *httpManager = [self httpManager];
    NSString *cacheKey = [httpManager.operation taskKeyForRequestURL:urlStr params:params];
    id oldData = [self oldDataCache:&cacheType forKey:cacheKey success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [httpManager postURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType forKey:cacheKey oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    ARHTTPManager *httpManager = [self httpManager];
    NSString *cacheKey = [httpManager.operation taskKeyForRequestURL:urlStr params:params];
    id oldData = [self oldDataCache:&cacheType forKey:cacheKey success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [httpManager putURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType forKey:cacheKey oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    ARHTTPManager *httpManager = [self httpManager];
    NSString *cacheKey = [httpManager.operation taskKeyForRequestURL:urlStr params:params];
    id oldData = [self oldDataCache:&cacheType forKey:cacheKey success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [httpManager patchURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType forKey:cacheKey oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    ARHTTPManager *httpManager = [self httpManager];
    NSString *cacheKey = [httpManager.operation taskKeyForRequestURL:urlStr params:params];
    id oldData = [self oldDataCache:&cacheType forKey:cacheKey success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [httpManager deleteURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType forKey:cacheKey oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

#pragma mark - Private

+ (__kindof ARDataCacheModel *)oldDataCache:(ARCacheType *)cacheType forKey:(NSString *)cacheKey success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    __kindof ARDataCacheModel *oldData;
    if (*cacheType & (ARCacheTypeOnlyLoad | ARCacheTypeUpdateIfNeeded)) {
        oldData = [self _dataCacheForKey:cacheKey];
        if (oldData) {
            ARLogDebug(@"Cache<%@>: %@", NSStringFromClass(self.class), oldData);
            
            if ((*cacheType & ARCacheTypeUpdateIfNeeded) && (oldData._AR_DATE_MODIFIED.timeIntervalSinceNow <= 0) && (oldData._AR_DATE_EXPIRED.timeIntervalSinceNow > 0)) {
                *cacheType = ARCacheTypeOnlyLoad;
            }
            if ((*cacheType & ARCacheTypeOnlyLoad) && success) {
                success(oldData, nil, YES);
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

+ (void)newDataCache:(ARCacheType)cacheType forKey:(NSString *)cacheKey oldData:(__kindof ARDataCacheModel *)oldData dataSource:(id)data msg:(NSString *)msg success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    if (![data isKindOfClass:NSDictionary.class]/* && ![data isKindOfClass:NSArray.class]*/) {
        if (failure) {
            failure(ARCacheErrorSource, @"Format of data source is wrong.");
        }
        ARAssert(NO, @"Cache<%@>: %ld, %@", NSStringFromClass(self.class), (long)ARCacheErrorSource,  @"Type of data source is wrong.");
        return;
    }
    
    if (cacheType & (ARCacheTypeOnlyUpdate | ARCacheTypeUpdateIfNeeded)) {
        if (oldData) {
            [oldData updateDataCache:data];
            if (success) {
                success(oldData, msg, NO);
            }
        } else {
            __kindof ARDataCacheModel *newData = [[self alloc] initDataCache:data];
            [newData _addOrUpdateDataCache:data forKey:cacheKey];
            if (success) {
                success(newData, msg, NO);
            }
        }
    } else {
        if (success) {
            __kindof ARDataCacheModel *newData = [[self alloc] initDataCache:data];
            [newData _clearPrimaryExistsTemp];
            newData = [newData ar_deepCopy];
            success(newData, msg, NO);
        }
    }
}

@end
