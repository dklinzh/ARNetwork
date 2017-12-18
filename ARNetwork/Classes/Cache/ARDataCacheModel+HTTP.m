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

@implementation ARDataCacheModel (HTTP)

+ (ARDataCacheManager *)cacheManager {
    return [ARDataCacheManager _managerWithModelClass:self];
}

+ (ARHTTPManager *)httpManager {
    return [self cacheManager].httpManager;
}

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[self httpManager] getURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[self httpManager] postURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[self httpManager] putURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[self httpManager] patchURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARCacheType)cacheType success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cacheType url:urlStr params:params success:success failure:failure];
    if (cacheType == ARCacheTypeOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[self httpManager] deleteURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cacheType url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

#pragma mark - Private

+ (__kindof ARDataCacheModel *)oldDataCache:(ARCacheType *)cacheType url:(NSString *)urlStr params:(NSDictionary *)params success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    __kindof ARDataCacheModel *oldData;
    if (*cacheType != ARCacheTypeNone) {
        oldData = [self _dataCacheWithUrl:urlStr params:params];
        if (oldData) {
            ARLogDebug(@"Cache<%@>: %@", NSStringFromClass(self.class), oldData);
            
            if ((*cacheType & ARCacheTypeOnlyLoad) && success) {
                success(oldData, nil, YES);
            }
            if ((*cacheType & ARCacheTypeUpdateIfNeeded) && (oldData._AR_DATE_MODIFIED.timeIntervalSinceNow <= 0) && (oldData._AR_DATE_EXPIRED.timeIntervalSinceNow > 0)) {
                *cacheType = ARCacheTypeOnlyLoad;
            }
        } else {
            ARLogWarn(@"Cache<%@>: %d, %@", NSStringFromClass(self.class), ARCacheErrorNone,  @"Have no cache in local.");
            
            if (*cacheType == ARCacheTypeOnlyLoad) {
                *cacheType |= ARCacheTypeOnlyUpdate;
            }
        }
    }
    return oldData;
}

+ (void)newDataCache:(ARCacheType)cacheType url:(NSString *)urlStr params:(NSDictionary *)params oldData:(__kindof ARDataCacheModel *)oldData dataSource:(id)data msg:(NSString *)msg success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    if (![data isKindOfClass:NSDictionary.class]/* && ![data isKindOfClass:NSArray.class]*/) {
        if (failure) {
            failure(ARCacheErrorSource, @"Format of data source is wrong.");
        }
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(self.class), ARCacheErrorSource,  @"Type of data source is wrong.");
        
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
            [newData _addDataCacheWithUrl:urlStr params:params];
            if (success) {
                success(newData, msg, NO);
            }
        }
    } else {
        if (success) {
            __kindof ARDataCacheModel *newData = [[self alloc] initDataCache:data];
            success(newData, msg, NO);
        }
    }
}

@end
