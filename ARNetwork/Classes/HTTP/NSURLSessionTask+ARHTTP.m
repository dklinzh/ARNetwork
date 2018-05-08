//
//  NSURLSessionTask+ARHTTP.m
//  ARNetwork
//
//  Created by Daniel Lin on 19/03/2018.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import "NSURLSessionTask+ARHTTP.h"
#import "_NSObject+ARProperty.h"

@implementation NSURLSessionTask (ARHTTP)

@dynamic ar_shouldCancelDuplicatedTask, ar_taskID;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self _addBasicProperty:@"ar_shouldCancelDuplicatedTask" encodingType:@encode(BOOL)];
        [self _addObjectProperty:@"ar_taskID" associationPolicy:OBJC_ASSOCIATION_COPY_NONATOMIC];
    });
}

@end
