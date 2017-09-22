//
//  ARHTTPManager.m
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"

static NSTimeInterval const kARDefaultTimeoutInterval = 30;
static NSMutableOrderedSet<Class> *arProtocolClasses;

@interface ARHTTPManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *taskCollections;
@end

@implementation ARHTTPManager
@synthesize timeoutInterval = _timeoutInterval;

#pragma mark - Override
- (instancetype)init {
    if (self = [super init]) {
        self.requestEncodedType = ARRequestEncodedTypeDefault;
        
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//        policy.validatesDomainName = NO;
//        policy.allowInvalidCertificates = YES;
//        self.securityPolicy = policy;
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    configuration = [self registerProtocolsOnSessionConfiguration:configuration];
    return [super initWithBaseURL:url sessionConfiguration:configuration];
}

#pragma mark - URLProtocol
+ (void)registerProtocolClass:(Class)protocolClass {
    if (!arProtocolClasses) {
        arProtocolClasses = [NSMutableOrderedSet orderedSet];
    }
    [arProtocolClasses addObject:protocolClass];
}

+ (void)unregisterProtocolClass:(Class)protocolClass {
    if (arProtocolClasses) {
        [arProtocolClasses removeObject:protocolClass];
        
        if (arProtocolClasses.count == 0) {
            arProtocolClasses = nil;
        }
    }
}

- (NSURLSessionConfiguration *)registerProtocolsOnSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if (arProtocolClasses) {
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        NSMutableArray *protocols = [[arProtocolClasses array] mutableCopy];
        [protocols addObjectsFromArray:configuration.protocolClasses];
        configuration.protocolClasses = [protocols copy];
        return configuration;
    }
    return configuration;
}

#pragma mark - HTTP

+ (instancetype)sharedInstance {
    static ARHTTPManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setHTTPHeaders:(NSDictionary *)headers {
    [headers enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] getURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
    return [self postURL:urlStr params:params filePaths:filePath ? @[filePath] : nil formName:formName progress:uploadProgress success:success failure:failure];
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self sharedInstance] postURL:urlStr params:params filePaths:filePaths formName:formName progress:uploadProgress success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
        for (NSString *path in filePaths) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:formName error:nil];
        }
    } progress:^(NSProgress * _Nonnull progress) {
        ARLogInfo(@"upload files - %@", progress.localizedDescription);
        if (uploadProgress) {
            uploadProgress(progress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
    urlStr = [self _delegateUrlIfNeeded:urlStr];
    if (!urlStr) {
        ARLogError(@"%@", @"HTTP URL IS NULL.");
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
- (NSString *)_delegateUrlIfNeeded:(NSString *)urlStr {
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
    ARLogSuccess(@"Response<%@>: %.f ms\n%@", key, (endTime - startTime) * 1000, data);
}

- (void)taskFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error forKey:(NSString *)key startTime:(CFTimeInterval)startTime {
    [self taskFailure:failure withError:error];
    
    CFTimeInterval endTime = CACurrentMediaTime();
    ARLogFailure(@"Response<%@>: %.f ms\n%@", key, (endTime - startTime) * 1000, error);
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

- (void)setExtraContentTypes:(NSSet<NSString *> *)extraContentTypes {
    _extraContentTypes = [extraContentTypes copy];
    if (!extraContentTypes) {
        return;
    }
    self.responseSerializer.acceptableContentTypes = [self.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:extraContentTypes];
}

- (ARHTTPOperation *)httpOperation {
    if (_httpOperation) {
        return _httpOperation;
    }
    return _httpOperation = [[ARHTTPOperation alloc] init];
}

- (void)setAllowRequestRedirection:(BOOL)allowRequestRedirection {
    if (_allowRequestRedirection != allowRequestRedirection) {
        _allowRequestRedirection = allowRequestRedirection;
        if (_allowRequestRedirection) {
            [self setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self _delegateUrlIfNeeded:request.URL.absoluteString]]];
                ARLogInfo(@"HTTPRedirection: %@ >->-> %@", response.URL, request.URL);
                return request;
            }];
        } else {
            [self setTaskWillPerformHTTPRedirectionBlock:nil];
        }
    }
}

- (void)setRequestEncodedType:(ARRequestEncodedType)requestEncodedType {
    _requestEncodedType = requestEncodedType;
    
    switch (requestEncodedType) {
        case ARRequestEncodedTypeJSON:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case ARRequestEncodedTypePlist:
            self.requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
        default:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    self.requestSerializer.timeoutInterval = self.timeoutInterval;
}

@end

@implementation ARHTTPManager (Session)

- (NSString *)getJSESSIONIDForURL:(NSString *)urlString {
    ARLogInfo(@"cookies: %@", NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies);
    
    NSURL *url = [NSURL URLWithString:[self _delegateUrlIfNeeded:urlString]];
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@%@/", url.scheme, url.host, url.path];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:urlStr]];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"JSESSIONID"]) {
            return cookie.value;
        }
    }
    
    return nil;
}

- (void)restoreSession:(NSString *)JSESSIONID forURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:[self _delegateUrlIfNeeded:urlString]];
    NSString *host = url.host;
    NSString *path = [NSString stringWithFormat:@"%@/", url.path];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setValue:@"JSESSIONID" forKey:NSHTTPCookieName];
    [cookieProperties setValue:JSESSIONID forKey:NSHTTPCookieValue];
    [cookieProperties setValue:host forKey:NSHTTPCookieDomain];
    [cookieProperties setValue:path forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    ARLogInfo(@"cookies: %@", NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies);
}

- (void)setHTTPHeaderWithAuthorization:(NSString *)value {
    [self.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
}

@end
