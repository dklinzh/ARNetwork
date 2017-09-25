//
//  ARHTTPConfiguration.m
//  ARNetwork
//
//  Created by Daniel Lin on 22/09/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.
//

#import "ARHTTPConfiguration.h"

@implementation ARHTTPConfiguration

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    static ARHTTPConfiguration *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
@end

@implementation ARHTTPConfiguration (RequestOperation)

- (NSTimeInterval)timeoutInterval {
    return 30;
}

@end
