//
//  ARHTTPRequest.m
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPRequest.h"

@implementation ARHTTPRequest

#pragma mark - ARHTTPRequestDelegate
- (NSString *)ar_taskKeyForRequestURL:(NSString *)urlStr {
    return urlStr;
}
@end
