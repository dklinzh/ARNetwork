//
//  ARHTTPOperation.m
//  ARNetwork
//
//  Created by Linzh on 12/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPOperation.h"

@implementation ARHTTPOperation

+ (instancetype)sharedInstance {
    static ARHTTPOperation *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)defaultOperation {
    return [[self alloc] init];
}

@end

@implementation ARHTTPOperation (Request)

- (NSTimeInterval)timeoutInterval {
    if ([self.requestOperation respondsToSelector:@selector(timeoutInterval)]) {
        return self.requestOperation.timeoutInterval;
    }
    
    return 30;
}

- (BOOL)allowRequestRedirection {
    if ([self.requestOperation respondsToSelector:@selector(allowRequestRedirection)]) {
        return self.requestOperation.allowRequestRedirection;
    }
    
    return NO;
}

- (ARRequestEncodedType)requestEncodedType {
    if ([self.requestOperation respondsToSelector:@selector(requestEncodedType)]) {
        return self.requestOperation.requestEncodedType;
    }
    
    return ARRequestEncodedTypeDefault;
}

- (NSOrderedSet<Class> *)protocolClasses {
    if ([self.requestOperation respondsToSelector:@selector(protocolClasses)]) {
        return self.requestOperation.protocolClasses;
    }
    
    return nil;
}

- (NSDictionary<NSString *,id> *)extraHTTPHeaders {
    if ([self.requestOperation respondsToSelector:@selector(extraHTTPHeaders)]) {
        return self.requestOperation.extraHTTPHeaders;
    }
    
    return nil;
}

- (NSString *)processedRequestURL:(NSString *)urlStr {
    if ([self.requestOperation respondsToSelector:@selector(processedRequestURL:)]) {
        return [self.requestOperation processedRequestURL:urlStr];
    }
    
    return urlStr;
}

- (NSString *)taskKeyForRequestURL:(NSString *)urlStr params:(NSDictionary *)params {
    if ([self.requestOperation respondsToSelector:@selector(taskKeyForRequestURL:params:)]) {
        return [self.requestOperation taskKeyForRequestURL:urlStr params:params];
    }
    
    return urlStr;
}

@end

@implementation ARHTTPOperation (Response)

- (NSSet<NSString *> *)extraContentTypes {
    if ([self.responseOperation respondsToSelector:@selector(extraContentTypes)]) {
        return self.responseOperation.extraContentTypes;
    }
    
    return nil;
}

- (void)responseSuccess:(ARHTTPResponseSuccess)success orFailure:(ARHTTPResponseFailure)failure withData:(id)data {
    if ([self.responseOperation respondsToSelector:@selector(responseSuccess:orFailure:withData:)]) {
        [self.responseOperation responseSuccess:success orFailure:failure withData:data];
        return;
    }
    
    if (data) {
        if (success) {
            success(data, @"操作成功"); // FIXME: localization
        }
    } else {
        if (failure) {
            failure(0, @"操作失败"); // FIXME: localization
        }
    }
}

- (void)responseFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error {
    if ([self.responseOperation respondsToSelector:@selector(responseFailure:withError:)]) {
        [self.responseOperation responseFailure:failure withError:error];
        return;
    }
    
    if (failure) {
        switch (error.code) {
            case -999: // request operation be canceled.
                failure(error.code, nil);
                break;
            case -1001:
            case -1005:
            case -1009: // network unreachable
                failure(error.code, @"网络异常，请稍后尝试。"); // FIXME: localization
                break;
            default:
                failure(error.code, @"系统繁忙，请稍后尝试。"); // FIXME: localization
                break;
        }
    }
}

@end
