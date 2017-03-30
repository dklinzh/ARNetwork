//
//  NSURLProtectionSpace+HTTPDNS.m
//  ARNetwork
//
//  Created by Linzh on 1/20/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <objc/runtime.h>
#import "ARHTTPDNS.h"
#import "NSObject+ARSwizzling.h"

@implementation NSURLProtectionSpace (HTTPDNS)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //    method_exchangeImplementations(class_getInstanceMethod(self, @selector(host)), class_getInstanceMethod(self, @selector(ar_host)));
        
        [self ar_swizzle:@selector(host) with:(IMP)ar_host store:(IMP *)&hostIMP];
    });
}

//- (NSString *)ar_host {
//    NSString *ip = [self ar_host];
//    ARHTTPDNS *httpDNS = [ARHTTPDNS sharedInstance];
//    if (httpDNS.isHttpDNSEnabled) {
//        NSString *host = [httpDNS getHostByIP:ip];
//        if (host) {
//            return host;
//        }
//    }
//    return ip;
//}

static NSString * ar_host(id self, SEL _cmd);
static NSString * (*hostIMP)(id self, SEL _cmd);

static NSString * ar_host(id self, SEL _cmd) {
    NSString *ip = hostIMP(self, _cmd);
    ARHTTPDNS *httpDNS = [ARHTTPDNS sharedInstance];
    if (httpDNS.isHttpDNSEnabled) {
        NSString *host = [httpDNS getHostByIP:ip];
        if (host) {
            return host;
        }
    }
    return ip;
}

@end
