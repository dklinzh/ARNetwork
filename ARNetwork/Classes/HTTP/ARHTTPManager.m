//
//  ARHTTPManager.m
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"
#import "NSURLSessionTask+ARHTTP.h"
#import "_NSString+ARSHA1.h"

#ifdef DEBUG

#define AR_TASK_TIMING_BEGIN(method) \
    NSURL *url = [NSURL URLWithString:urlStr]; \
    NSString *key = [NSString stringWithFormat:@"%@<%@>", method, url.relativePath]; \
    ARLogDebug(@"Request %@:\n%@", key, params); \
    CFTimeInterval startTime = CACurrentMediaTime();

#define AR_TASK_TIMING_END(info) \
    CFTimeInterval endTime = CACurrentMediaTime(); \
    if ([info isKindOfClass:NSError.class]) { \
        ARLogFailure(@"Response %@:: %.f ms\n%@", key, (endTime - startTime) * 1000, info); \
    } else { \
        ARLogSuccess(@"Response %@:: %.f ms\n%@", key, (endTime - startTime) * 1000, info); \
    } \
    CFTimeInterval startTime = CACurrentMediaTime();

#define AR_RESPONSE_PROCESS_COMPLETED(result) \
    endTime = CACurrentMediaTime(); \
    CFTimeInterval duration = (endTime - startTime) * 1000; \
    if (duration > 150) { \
        ARLogWarn(@"%@ Process Completed %@:: %.f ms", result ? @"✅" : @"❌", key, duration); \
    } else { \
        ARLogVerbose(@"%@ Process Completed %@:: %.f ms", result ? @"✅" : @"❌", key, duration); \
    }

#else

#define AR_TASK_TIMING_BEGIN(method)
#define AR_TASK_TIMING_END(info)
#define AR_RESPONSE_PROCESS_COMPLETED(result)

#endif

@interface AFHTTPSessionManager ()
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

@interface ARHTTPManager ()
@property (nonatomic, strong) ARHTTPOperation *operation;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *sessionTaskIDs;
@property (nonatomic, strong) NSMutableSet<NSString *> *customHeaderFields;
@end

@implementation ARHTTPManager

- (instancetype)initWithHTTPOperation:(ARHTTPOperation *)operation {
    return [self initWithBaseURL:nil sessionConfiguration:nil httpOperation:operation];
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    return [self initWithBaseURL:url sessionConfiguration:configuration httpOperation:[ARHTTPOperation sharedInstance]];
}

- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(NSURLSessionConfiguration *)configuration httpOperation:(ARHTTPOperation *)operation {
    if (self = [super initWithBaseURL:url sessionConfiguration:ar_urlSessionConfigurationWithProtocolClasses(configuration, operation.protocolClasses)]) {
        _operation = operation;
        
        switch (operation.requestEncodedType) {
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
        
        NSDictionary<NSString *, NSString *> *httpHeaders = operation.extraHTTPHeaders;
        if (httpHeaders) {
            [self setHTTPHeaderFields:httpHeaders];
        }
        
        self.requestSerializer.timeoutInterval = operation.timeoutInterval;
        
        NSSet<NSString *> *contentTypes = operation.extraContentTypes;
        if (contentTypes) {
            self.responseSerializer.acceptableContentTypes = [self.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:contentTypes];
        }
        
        if (operation.allowRequestRedirection) {
            __weak __typeof(self)weakSelf = self;
            [self setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:[strongSelf.operation processedRequestURL:request.URL.absoluteString]]];
                ARLogInfo(@"HTTPRedirection: %@ >->-> %@", response.URL, request.URL);
                return request;
            }];
        } else {
            [self setTaskWillPerformHTTPRedirectionBlock:nil];
        }
        
        [self validateSSLCertificatesInBundle:operation.certificatesBundle];
    }
    
    return self;
}

static inline NSURLSessionConfiguration * ar_urlSessionConfigurationWithProtocolClasses(NSURLSessionConfiguration *configuration, NSOrderedSet<Class> *protocolClasses) {
    if (!protocolClasses) {
        return configuration;
    }
    
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    NSMutableArray *protocols = [[protocolClasses array] mutableCopy];
    [protocols addObjectsFromArray:configuration.protocolClasses];
    configuration.protocolClasses = protocols;
    return configuration;
}

+ (instancetype)sharedInstance {
    static ARHTTPManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] getURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];
    
    AR_TASK_TIMING_BEGIN(@"GET");
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [self GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AR_TASK_TIMING_END(responseObject);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] postURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];

    AR_TASK_TIMING_BEGIN(@"POST");
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [self POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AR_TASK_TIMING_END(responseObject);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] postURL:urlStr params:params filePath:filePath formName:formName progress:uploadProgress success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    return [self postURL:urlStr params:params filePaths:filePath ? @[filePath] : nil formName:formName progress:uploadProgress success:success failure:failure];
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] postURL:urlStr params:params filePaths:filePaths formName:formName progress:uploadProgress success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];

    AR_TASK_TIMING_BEGIN(@"POST");
    __weak __typeof(self)weakSelf = self;
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
        AR_TASK_TIMING_END(responseObject);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] putURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];

    AR_TASK_TIMING_BEGIN(@"PUT");
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [self PUT:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AR_TASK_TIMING_END(responseObject);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] patchURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];

    AR_TASK_TIMING_BEGIN(@"PATCH");
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [self PATCH:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AR_TASK_TIMING_END(responseObject);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] deleteURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];

    AR_TASK_TIMING_BEGIN(@"DELETE");
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [self DELETE:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AR_TASK_TIMING_END(responseObject);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

+ (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] headURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    [self cancelDuplicatedSessionTaskForKey:taskKey];

    AR_TASK_TIMING_BEGIN(@"HEAD");
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [self HEAD:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task) {
        AR_TASK_TIMING_END(@"");
        if (success) {
            success(task);
        }
        AR_RESPONSE_PROCESS_COMPLETED(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AR_TASK_TIMING_END(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.operation response:(NSHTTPURLResponse *)task.response onFailure:failure withError:error];
        AR_RESPONSE_PROCESS_COMPLETED(NO);
    }];
    task.ar_shouldCancelDuplicatedTask = YES;
    task.ar_taskID = taskKey;
    
    [self.sessionTaskIDs setValue:@(task.taskIdentifier) forKey:taskKey];
    
    return task;
}

- (void)cancelAllSessionTasks {
    for (NSURLSessionTask *task in self.tasks) {
        [task cancel];
    }
    
    [self.sessionTaskIDs removeAllObjects];
}

- (void)validateSSLCertificatesInBundle:(NSBundle *)bundle {
    if (bundle) {
        //A security policy configured with `AFSSLPinningModeCertificate/AFSSLPinningModePublicKey` can only be applied on a manager with a secure base URL (i.e. https)
        if (!self.baseURL) {
            self.baseURL = [NSURL URLWithString:@"https://"];
        }
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[AFSecurityPolicy certificatesInBundle:bundle]];
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName = YES;
        self.securityPolicy = securityPolicy;
    }
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (value) {
        [self.customHeaderFields addObject:field];
    } else {
        [self.customHeaderFields removeObject:field];
    }
    
    [self.requestSerializer setValue:value forHTTPHeaderField:field];
}

- (void)setHTTPHeaderFields:(NSDictionary<NSString *, NSString *> *)headerFields {
    [headerFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)removeAllCustomHeaderFields {
    for (NSString *field in self.customHeaderFields) {
        [self.requestSerializer setValue:nil forHTTPHeaderField:field];
    }
    
    [self.customHeaderFields removeAllObjects];
}

#pragma mark - Private

- (void)cancelDuplicatedSessionTaskForKey:(NSString *)taskKey {
    NSNumber *sessionTaskID = self.sessionTaskIDs[taskKey];
    if (sessionTaskID) {
        NSUInteger taskID = sessionTaskID.unsignedIntegerValue;
        for (NSURLSessionTask *task in self.tasks) {
            if (task.taskIdentifier == taskID) {
                if (task.ar_shouldCancelDuplicatedTask && task.state != NSURLSessionTaskStateCanceling && task.state != NSURLSessionTaskStateCompleted) {
                    [task cancel];
                }
                break;
            }
        }
        
        [self.sessionTaskIDs removeObjectForKey:taskKey];
    }
}

- (NSMutableDictionary<NSString *,NSNumber *> *)sessionTaskIDs {
    if (_sessionTaskIDs) {
        return _sessionTaskIDs;
    }
    
    return _sessionTaskIDs = [[NSMutableDictionary alloc] init];
}

- (NSMutableSet<NSString *> *)customHeaderFields {
    if (_customHeaderFields) {
        return _customHeaderFields;
    }
    
    return _customHeaderFields = [[NSMutableSet alloc] init];
}

@end

@implementation ARHTTPManager (Session)

#pragma mark - Cookies
static NSString *const ARNetworkCookiesDomainName = @"dklinzh.arnetwork.cookies";

static inline NSUserDefaults * ar_cookieStorage() {
    return [[NSUserDefaults alloc] initWithSuiteName:ARNetworkCookiesDomainName];
}

static inline NSString * ar_cookieKey(NSURL *url) {
    return [NSString stringWithFormat:@"cookie.%@", url.host].ar_SHA1;
}

+ (void)storeCookiesForURL:(NSString *)url {
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return;
    }
    
    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:URL];
    NSMutableArray *propertyList = [NSMutableArray array];
    for (NSHTTPCookie *cookie in cookies) {
        [propertyList addObject:cookie.properties];
    }
    if (propertyList.count > 0) {
        NSUserDefaults *userDefaults = ar_cookieStorage();
        [userDefaults setObject:propertyList forKey:ar_cookieKey(URL)];
    }
}

+ (void)restoreCookiesForURL:(NSString *)url {
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return;
    }
    
    NSUserDefaults *userDefaults = ar_cookieStorage();
    NSArray *propertyList = [userDefaults arrayForKey:ar_cookieKey(URL)];
    for (NSDictionary *properties in propertyList) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookie:cookie];
    }
}

+ (void)clearCookiesForURL:(NSString *)url {
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return;
    }
    
    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:URL];
    for (NSHTTPCookie *cookie in cookies) {
        [NSHTTPCookieStorage.sharedHTTPCookieStorage deleteCookie:cookie];
    }
    
    NSUserDefaults *userDefaults = ar_cookieStorage();
    [userDefaults removeObjectForKey:ar_cookieKey(URL)];
}

+ (void)clearAllCookies {
    NSArray *cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies;
    for (NSHTTPCookie *cookie in cookies) {
        [NSHTTPCookieStorage.sharedHTTPCookieStorage deleteCookie:cookie];
    }
    
    NSUserDefaults *userDefaults = ar_cookieStorage();
    [userDefaults removePersistentDomainForName:ARNetworkCookiesDomainName];
}

#pragma mark - JSESSIONID
- (NSString *)JSESSIONIDForURL:(NSString *)urlString {
    ARLogInfo(@"cookies: %@", NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies);
    
    NSURL *url = [NSURL URLWithString:[self.operation processedRequestURL:urlString]];
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
    NSURL *url = [NSURL URLWithString:[self.operation processedRequestURL:urlString]];
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

#pragma mark -
- (void)setHTTPHeaderWithAuthorization:(NSString *)value {
    [self setValue:value forHTTPHeaderField:@"Authorization"];
}

@end
