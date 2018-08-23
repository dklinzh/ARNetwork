//
//  ARHTTPOperation.m
//  ARNetwork
//
//  Created by Linzh on 12/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPOperation.h"
#import "_NSString+ARSHA1.h"

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

- (NSBundle *)certificatesBundle {
    if ([self.requestOperation respondsToSelector:@selector(certificatesBundle)]) {
        return self.requestOperation.certificatesBundle;
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
    
    return ar_sessionTaskKey(urlStr, params);
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

- (void)response:(NSHTTPURLResponse *)response onFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error {
    if ([self.responseOperation respondsToSelector:@selector(response:onFailure:withError:)]) {
        [self.responseOperation response:(NSHTTPURLResponse *)response onFailure:failure withError:error];
        return;
    }
    
    if (failure) {
        NSInteger errorCode = error.code;
        switch (errorCode) {
            case NSURLErrorAppTransportSecurityRequiresSecureConnection: // ATS
                failure(errorCode, @"ATS_ERROR");
                break;
            case NSURLErrorCancelled: // request operation be canceled.
                failure(errorCode, nil);
                break;
            case NSURLErrorTimedOut:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorDNSLookupFailed:
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorInternationalRoamingOff:
            case NSURLErrorCallIsActive:
            case NSURLErrorDataNotAllowed:
                // network unreachable
                failure(errorCode, @"网络异常，请稍后尝试。"); // FIXME: localization
                break;
            default:
                failure(errorCode, @"系统繁忙，请稍后尝试。"); // FIXME: localization
                break;
        }
    }
}

@end
