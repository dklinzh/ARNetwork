//
//  ARHTTPMock.m
//  ARNetwork
//
//  Created by Daniel Lin on 16/11/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.

#ifdef DEBUG

#import "ARHTTPMock.h"
@import OHHTTPStubs;

static BOOL MockEnabled = YES;

@implementation ARHTTPMock

+ (void)setEnabled:(BOOL)enabled {
    MockEnabled = enabled;
    [OHHTTPStubs setEnabled:enabled];
    if (enabled) {
        [OHHTTPStubs onStubActivation:^(NSURLRequest * _Nonnull request, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub) {
            ARLogWarn(@"Mock request %@ by file: `%@`.", ar_httpMockKey(request.HTTPMethod, request.URL), stub.name);
        }];
    } else {
        [OHHTTPStubs onStubActivation:nil];
        [self removeAllMocks];
    }
}

+ (void)removeAllMocks {
    [OHHTTPStubs removeAllStubs];
    [ar_httpMocks() removeAllObjects];
}

static NSMutableDictionary<NSString *, id<OHHTTPStubsDescriptor>> * ar_httpMocks() {
    static NSMutableDictionary<NSString *, id<OHHTTPStubsDescriptor>> *ar_httpMocks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ar_httpMocks = [NSMutableDictionary dictionary];
    });
    return ar_httpMocks;
}

static inline NSString * ar_httpMockKey(NSString *httMethod, NSURL *url) {
    return [NSString stringWithFormat:@"%@<%@%@>", httMethod, url.host, url.path];
}

+ (void)httpMethod:(NSString *)method requestURL:(NSString *)urlString responseByMainBundleFile:(NSString *)fileName {
    if (!MockEnabled) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    ARAssert(url, @"Mock url: `%@` is invalid.", urlString);
    if (!url) {
        return;
    }
    
    NSString *mockKey = ar_httpMockKey(method, url);
    __weak id<OHHTTPStubsDescriptor> stub = [ar_httpMocks() objectForKey:mockKey];
    if (stub) {
        [OHHTTPStubs removeStub:stub];
        [ar_httpMocks() removeObjectForKey:mockKey];
    }
    
    NSString *filePath = OHPathForFileInBundle(fileName, [NSBundle mainBundle]);
    ARAssert(filePath, @"Mock file: `%@` is not found.", fileName);
    if (!filePath) {
        return;
    }
    
    __weak id<OHHTTPStubsDescriptor> _stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSURL *_url = request.URL;
        if (!_url) {
            return NO;
        }
        
        return [ar_httpMockKey(request.HTTPMethod, _url) isEqualToString:mockKey];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:filePath statusCode:200 headers:@{@"Content-Type": @"application/json"}];
    }];
    _stub.name = fileName;
    
    [ar_httpMocks() setObject:_stub forKey:mockKey];
}

+ (void)httpMethod:(NSString *)method requestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:method requestURL:urlString responseByMainBundleFile:[fileName stringByAppendingString:@".json"]];
}

+ (void)getRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:@"GET" requestURL:urlString responseByMainBundleJSONFile:fileName];
}

+ (void)postRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:@"POST" requestURL:urlString responseByMainBundleJSONFile:fileName];
}

+ (void)putRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:@"PUT" requestURL:urlString responseByMainBundleJSONFile:fileName];
}

+ (void)patchRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:@"PATCH" requestURL:urlString responseByMainBundleJSONFile:fileName];
}

+ (void)deleteRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:@"DELETE" requestURL:urlString responseByMainBundleJSONFile:fileName];
}

+ (void)headRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName {
    [self httpMethod:@"HEAD" requestURL:urlString responseByMainBundleJSONFile:fileName];
}

@end

#endif
