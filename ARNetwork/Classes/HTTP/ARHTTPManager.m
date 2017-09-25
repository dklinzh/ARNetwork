//
//  ARHTTPManager.m
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"

#ifdef DEBUG

#define AR_TASK_TIMING_BEGIN \
    CFTimeInterval startTime = CACurrentMediaTime(); \
    NSString *taskKey = [self taskKeyForUrl:urlStr params:params];

#define AR_TASK_TIMING_END(info) \
    CFTimeInterval endTime = CACurrentMediaTime(); \
    ARLogFailure(@"Response<%@>: %.f ms\n%@", taskKey, (endTime - startTime) * 1000, info);

#else

#define AR_TASK_TIMING_BEGIN
#define AR_TASK_TIMING_END(info)

#endif

@interface ARHTTPManager ()
@property (nonatomic, strong) ARHTTPOperation *operation;
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
    _operation = operation;
    
    if (self = [super initWithBaseURL:url sessionConfiguration:ar_urlSessionConfigurationWithProtocolClasses(configuration, operation.protocolClasses)]) {
        
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
        
        NSDictionary<NSString *, id> *httpHeaders = operation.extraHTTPHeaders;
        if (httpHeaders) {
            [httpHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [self.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
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
    
    AR_TASK_TIMING_BEGIN
    NSURLSessionDataTask *task = [self GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_TASK_TIMING_END(responseObject)
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
    return task;
}

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] postURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];

    AR_TASK_TIMING_BEGIN
    NSURLSessionDataTask *task = [self POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_TASK_TIMING_END(responseObject)
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
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

    AR_TASK_TIMING_BEGIN
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
        [self.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_TASK_TIMING_END(responseObject)
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
    return task;
}

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] putURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];

    AR_TASK_TIMING_BEGIN
    NSURLSessionDataTask *task = [self PUT:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_TASK_TIMING_END(responseObject)
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
    return task;
}

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] patchURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];

    AR_TASK_TIMING_BEGIN
    NSURLSessionDataTask *task = [self PATCH:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_TASK_TIMING_END(responseObject)
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
    return task;
}

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] deleteURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];

    AR_TASK_TIMING_BEGIN
    NSURLSessionDataTask *task = [self DELETE:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.operation responseSuccess:success orFailure:failure withData:responseObject];
        AR_TASK_TIMING_END(responseObject)
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
    return task;
}

+ (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure {
    NSURLSessionDataTask *task = [[self manager] headURL:urlStr params:params success:success failure:failure];
    return task;
}

- (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure {
    urlStr = [self.operation processedRequestURL:urlStr];

    AR_TASK_TIMING_BEGIN
    NSURLSessionDataTask *task = [self HEAD:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task) {
        if (success) {
            success(task);
        }
        AR_TASK_TIMING_END("")
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.operation responseFailure:failure withError:error];
        AR_TASK_TIMING_END(error)
    }];
    return task;
}

#pragma mark - Private

- (NSString *)taskKeyForUrl:(NSString *)urlStr params:(NSDictionary *)params {
    NSString *taskKey = [self.operation taskKeyForRequestURL:urlStr params:params];
    
    ARLogDebug(@"Request<%@>:\n%@", taskKey, urlStr);
    return taskKey;
}

@end

@implementation ARHTTPManager (Session)

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

- (void)setHTTPHeaderWithAuthorization:(NSString *)value {
    [self.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
}

@end
