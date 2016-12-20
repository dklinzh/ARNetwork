//
//  ARHTTPManager+Cache.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager+Cache.h"
#import "ARDataCacheModel.h"

@implementation ARHTTPManager (Cache)

#pragma mark - HTTP
+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] getURL:urlStr params:params dataCache:cache dataClass:arClass success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    if (![arClass isSubclassOfClass:[ARDataCacheModel class]]) {
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorModel,  @"Format of class model is wrong.");
        
        return nil;
    }
    
    id oldData = [self oldDataCache:&cache dataClass:arClass url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self getURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache dataClass:arClass url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] postURL:urlStr params:params dataCache:cache dataClass:arClass success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    if (![arClass isSubclassOfClass:[ARDataCacheModel class]]) {
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorModel,  @"Format of class model is wrong.");
        
        return nil;
    }
    
    id oldData = [self oldDataCache:&cache dataClass:arClass url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self postURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache dataClass:arClass url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] putURL:urlStr params:params dataCache:cache dataClass:arClass success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    if (![arClass isSubclassOfClass:[ARDataCacheModel class]]) {
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorModel,  @"Format of class model is wrong.");
        
        return nil;
    }
    
    id oldData = [self oldDataCache:&cache dataClass:arClass url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self putURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache dataClass:arClass url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] patchURL:urlStr params:params dataCache:cache dataClass:arClass success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    if (![arClass isSubclassOfClass:[ARDataCacheModel class]]) {
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorModel,  @"Format of class model is wrong.");
        
        return nil;
    }
    
    id oldData = [self oldDataCache:&cache dataClass:arClass url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self patchURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache dataClass:arClass url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] deleteURL:urlStr params:params dataCache:cache dataClass:arClass success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params dataCache:(ARDataCache)cache dataClass:(Class)arClass success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    if (![arClass isSubclassOfClass:[ARDataCacheModel class]]) {
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorModel,  @"Format of class model is wrong.");
        
        return nil;
    }
    
    id oldData = [self oldDataCache:&cache dataClass:arClass url:urlStr params:params success:success failure:failure];
    if (cache == ARDataCacheOnlyLoad) {
        return nil;
    }
    
    NSURLSessionDataTask *task = [self deleteURL:urlStr params:params success:^(id data, NSString *msg) {
        [self newDataCache:cache dataClass:arClass url:urlStr params:params oldData:oldData dataSource:data msg:msg success:success failure:failure];
    } failure:^(NSInteger code, NSString *msg) {
        if (failure) {
            failure(code, msg);
        }
    }];
    return task;
}

#pragma mark - Private
- (id)oldDataCache:(ARDataCache *)cache dataClass:(Class)arClass url:(NSString *)urlStr params:(NSDictionary *)params success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    id oldData;
    if (*cache & ARDataCacheOnlyLoad) {
        oldData = [arClass dataCacheWithUrl:urlStr params:params];
        if (oldData) {
            ARLogDebug(@"Cache<%@>: %@", NSStringFromClass(arClass), oldData);
            
            if (success) {
                success(oldData, nil, YES);
            }
        } else {
            //            if (failure) {
            //                failure(ARCacheErrorNone, @"Have no cache in local.");
            //            }
            ARLogWarn(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorNone,  @"Have no cache in local.");
            
            *cache |= ARDataCacheOnlyUpdate;
        }
    }
    return oldData;
}

- (void)newDataCache:(ARDataCache)cache dataClass:(Class)arClass url:(NSString *)urlStr params:(NSDictionary *)params oldData:(id)oldData dataSource:(id)data msg:(NSString *)msg success:(ARCacheResponseSuccess)success failure:(ARCacheResponseFailure)failure {
    if (![data isKindOfClass:[NSDictionary class]]) {
        if (failure) {
            failure(ARCacheErrorSource, @"Format of data source is wrong.");
        }
        ARLogError(@"Cache<%@>: %d, %@", NSStringFromClass(arClass), ARCacheErrorSource,  @"Format of data source is wrong.");
        
        return;
    }
    
    id newData = [arClass alloc];
    if ([newData respondsToSelector:@selector(initWithValue:)]) {
        [newData initWithValue:data];
    }
    if (cache & ARDataCacheOnlyUpdate) {
        if (oldData) {
            if ([oldData respondsToSelector:@selector(updateDataCacheWithData:)]) {
                [oldData updateDataCacheWithData:data];
            }
            if (success) {
                success(newData, msg, NO);
            }
        } else {
            if ([newData respondsToSelector:@selector(addDataCacheWithUrl:params:)]) {
                [newData addDataCacheWithUrl:urlStr params:params];
            }
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
