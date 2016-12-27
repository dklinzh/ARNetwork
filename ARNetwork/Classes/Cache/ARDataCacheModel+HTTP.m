//
//  ARDataCacheModel+HTTP.m
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel+HTTP.h"
#import "ARHTTPManager.h"

@interface ARDataCacheModel ()
+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;
- (void)addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;
@end

@implementation ARDataCacheModel (HTTP)
#pragma mark - HTTP
+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[ARHTTPManager sharedInstance] getURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[ARHTTPManager sharedInstance] postURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[ARHTTPManager sharedInstance] putURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[ARHTTPManager sharedInstance] patchURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    id oldData = [self oldDataCache:&cache url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [[ARHTTPManager sharedInstance] deleteURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

#pragma mark - Private
+ (__kindof ARDataCacheModel *)oldDataCache:(ARDataCache *)cache url:(NSString *)urlStr params:(NSDictionary *)params success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    __kindof ARDataCacheModel *oldData;
    if (*cache & (ARDataCacheOnlyLoad | ARDataCacheUpdateIfNeeded)) {
        oldData = [self dataCacheWithUrl:urlStr params:params];
        if (oldData) {
            ARLogDebug(@"Cache<%@>: %@", NSStringFromClass(self.class), oldData);
            
            if ((*cache & ARDataCacheOnlyLoad) && success) {
                success(oldData, nil, YES);
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

+ (void)newDataCache:(ARDataCache)cache url:(NSString *)urlStr params:(NSDictionary *)params oldData:(__kindof ARDataCacheModel *)oldData dataSource:(id)data msg:(NSString *)msg success:(ARDataCacheSuccess)success failure:(ARDataCacheFailure)failure {
    if (![data isKindOfClass:NSDictionary.class]/* && ![data isKindOfClass:NSArray.class]*/) {
        if (failure) {
            failure(ARCacheErrorSource, @"Format of data source is wrong.");
        }
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(self.class), ARCacheErrorSource,  @"Type of data source is wrong.");
        
        return;
    }
    
    __kindof ARDataCacheModel *newData = [[self alloc] initDataCacheWithData:data];
    if (cache & (ARDataCacheOnlyUpdate | ARDataCacheUpdateIfNeeded)) {
        if (oldData) {
            [oldData updateDataCacheWithData:data];
            if (success) {
                success(newData, msg, NO);
            }
        } else {
            [newData addDataCacheWithUrl:urlStr params:params];
            if (success) {
                success(newData, msg, NO);
            }
        }
    } else {
        if (success) {
            success(newData, msg, NO);
        }
    }
}

@end
