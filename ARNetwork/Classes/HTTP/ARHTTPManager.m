//
//  ARHTTPManager.m
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"

static const NSTimeInterval kARDefaultTimeoutInterval = 30;

@interface ARHTTPManager ()
@property (nonatomic, strong) NSMutableSet<NSString *> *acceptableContentTypes;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *taskCollections;
@end

@implementation ARHTTPManager
@synthesize timeoutInterval = _timeoutInterval;

#pragma mark - Override
- (instancetype)init {
    if (self = [super init]) {
        self.requestSerializer.timeoutInterval = self.timeoutInterval;
        self.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
        
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//        policy.validatesDomainName = NO;
//        policy.allowInvalidCertificates = YES;
//        self.securityPolicy = policy;
    }
    return self;
}

//+ (instancetype)allocWithZone:(struct _NSZone *)zone {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken,^{
//        sharedInstance = [super allocWithZone:zone];
//    });
//    return sharedInstance;
//}

#pragma mark - HTTP
static ARHTTPManager *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] getURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [self taskSuccess:success failure:failure withData:responseObject forKey:taskKey startTime:startTime];
#else
        [self taskSuccess:success failure:failure withData:responseObject];
#endif
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] postURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [self taskSuccess:success failure:failure withData:responseObject forKey:taskKey startTime:startTime];
#else
        [self taskSuccess:success failure:failure withData:responseObject];
#endif
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] postURL:urlStr params:params filePath:filePath formName:formName progress:uploadProgress success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:formName error:nil];
    } progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [self taskSuccess:success failure:failure withData:responseObject forKey:taskKey startTime:startTime];
#else
        [self taskSuccess:success failure:failure withData:responseObject];
#endif
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] putURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self PUT:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [self taskSuccess:success failure:failure withData:responseObject forKey:taskKey startTime:startTime];
#else
        [self taskSuccess:success failure:failure withData:responseObject];
#endif
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] patchURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self PATCH:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [self taskSuccess:success failure:failure withData:responseObject forKey:taskKey startTime:startTime];
#else
        [self taskSuccess:success failure:failure withData:responseObject];
#endif
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] deleteURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self DELETE:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [self taskSuccess:success failure:failure withData:responseObject forKey:taskKey startTime:startTime];
#else
        [self taskSuccess:success failure:failure withData:responseObject];
#endif
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

+ (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] headURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"HTTP URL IS NULL.");
        if (failure) {
            failure(0, @"HTTP URL IS NULL.");
        }
        return nil;
    }
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];
#endif
    NSURLSessionDataTask *task = [self HEAD:urlStr parameters:params success:success failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        [self taskFailure:failure withError:error forKey:taskKey startTime:startTime];
#else
        [self taskFailure:failure withError:error];
#endif
    }];
    return task;
}

#pragma mark - Private
- (NSString *)delegateUrlIfNeeded:(NSString *)urlStr {
    return urlStr;
}

- (NSString *)taskKeyForUrl:(NSString *)urlStr params:(NSDictionary *)params {
    NSString *taskKey;
    if ([self.httpOperation respondsToSelector:@selector(ar_taskKeyForRequestURL:params:)]) {
        taskKey = [self.httpOperation ar_taskKeyForRequestURL:urlStr params:params];
    }
    
    ARLogDebug(@"Request<%@>:\n%@", taskKey, urlStr);
    return taskKey;
}

- (void)taskSuccess:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure withData:(id)data {
    if ([self.httpOperation respondsToSelector:@selector(ar_onSuccess:onFailure:withData:)]) {
        [self.httpOperation ar_onSuccess:success onFailure:failure withData:data];
    }
}

- (void)taskFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error {
    if ([self.httpOperation respondsToSelector:@selector(ar_onFailure:withError:)]) {
        [self.httpOperation ar_onFailure:failure withError:error];
    }
}

#ifdef DEBUG
- (void)taskSuccess:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure withData:(id)data forKey:(NSString *)key startTime:(CFTimeInterval)startTime {
    [self taskSuccess:success failure:failure withData:data];
    
    CFTimeInterval endTime = CACurrentMediaTime();
    ARLogDebug(@"Response<%@>: %.f ms\n%@", key, (endTime - startTime) * 1000, data);
}

- (void)taskFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error forKey:(NSString *)key startTime:(CFTimeInterval)startTime {
    [self taskFailure:failure withError:error];
    
    CFTimeInterval endTime = CACurrentMediaTime();
    ARLogError(@"Response<%@>: %.f ms\n%@", key, (endTime - startTime) * 1000, error);
}
#endif

#pragma mark -
- (NSTimeInterval)timeoutInterval {
    if (_timeoutInterval > 0) {
        return _timeoutInterval;
    }
    return kARDefaultTimeoutInterval;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    if (timeoutInterval > 0) {
        _timeoutInterval = timeoutInterval;
        self.requestSerializer.timeoutInterval = _timeoutInterval;
    }
}

- (NSMutableSet<NSString *> *)acceptableContentTypes {
    if (_acceptableContentTypes) {
        return _acceptableContentTypes;
    }
    _acceptableContentTypes = [NSMutableSet setWithSet:self.responseSerializer.acceptableContentTypes];
    [_acceptableContentTypes addObject:@"text/html"];
    return _acceptableContentTypes;
}

- (ARHTTPOperation *)httpOperation {
    if (_httpOperation) {
        return _httpOperation;
    }
    return _httpOperation = [[ARHTTPOperation alloc] init];
}
@end
