//
//  ARHTTPManager+HTTPDNS.m
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"
#import "ARHTTPDNS.h"
#import <objc/runtime.h>

@interface ARHTTPManager ()
- (NSString *)_delegateUrlIfNeeded:(NSString *)urlStr;
@end

@implementation ARHTTPManager (HTTPDNS)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(_delegateUrlIfNeeded:)), class_getInstanceMethod(self, @selector(ar_delegateUrlIfNeeded:)));
    });
}

- (NSString *)ar_delegateUrlIfNeeded:(NSString *)urlStr {
    return [ARHTTPDNS getIpURLByHostURLAsync:urlStr onDNS:^(NSString *host, NSString *ip) {
        if (ip) {
            [self.requestSerializer setValue:host forHTTPHeaderField:@"Host"];
        }
    }];
}

@end
