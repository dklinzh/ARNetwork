//
//  ARNetworkIndicator.m
//  ARNetwork
//
//  Created by Linzh on 1/9/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "ARNetworkIndicator.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@implementation ARNetworkIndicator
static ARNetworkIndicator *sharedInstance = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setActive:(BOOL)active {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = active;
}
@end
