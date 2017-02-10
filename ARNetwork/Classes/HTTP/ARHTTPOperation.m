//
//  ARHTTPOperation.m
//  ARNetwork
//
//  Created by Linzh on 12/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPOperation.h"

@implementation ARHTTPOperation

#pragma mark - ARHTTPRequestDelegate
- (NSString *)ar_taskKeyForRequestURL:(NSString *)urlStr params:(NSDictionary *)params {
    return urlStr;
}

#pragma mark - ARHTTPResponseDelegate
- (void)ar_onSuccess:(ARHTTPResponseSuccess)success onFailure:(ARHTTPResponseFailure)failure withData:(id)data {
    if (data) {
        if (success) {
            success(data, @"操作成功");
        }
    } else {
        if (failure) {
            failure(0, @"操作失败");
        }
    }
}

- (void)ar_onFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error {
    if (failure) {
        switch (error.code) {
            case -999: // request operation be canceled.
                failure(error.code, nil);
                break;
            case -1001:
            case -1005:
            case -1009: {// network unreachable
                failure(error.code, @"网络异常，请稍后尝试。");
            }
                break;
            default:
                failure(error.code, @"系统繁忙，请稍后尝试。");
                break;
        }
    }
}
@end
