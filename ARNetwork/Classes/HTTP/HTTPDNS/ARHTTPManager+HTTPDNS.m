//
//  ARHTTPManager+HTTPDNS.m
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPManager.h"
#import "ARHTTPDNS.h"

@interface ARHTTPManager ()
- (NSString *)delegateUrlIfNeeded:(NSString *)urlStr;
@end

@implementation ARHTTPManager (HTTPDNS)
- (NSString *)delegateUrlIfNeeded:(NSString *)urlStr {
    return [ARHTTPDNS getIpURLByHostURLAsync:urlStr];
}
@end
