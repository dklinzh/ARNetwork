//
//  NSURLSessionTask+ARHTTP.m
//  ARNetwork
//
//  Created by Daniel Lin on 19/03/2018.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import "NSURLSessionTask+ARHTTP.h"
#import <objc/runtime.h>

@implementation NSURLSessionTask (ARHTTP)

- (BOOL)ar_shouldCancelDuplicatedTask {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(ar_shouldCancelDuplicatedTask)) boolValue];
}

- (void)setAr_shouldCancelDuplicatedTask:(BOOL)ar_shouldCancelDuplicatedTask {
    if (ar_shouldCancelDuplicatedTask != self.ar_shouldCancelDuplicatedTask) {
        SEL keySEL = @selector(ar_shouldCancelDuplicatedTask);
        NSString *key = NSStringFromSelector(keySEL);
        [self willChangeValueForKey:key];
        objc_setAssociatedObject(self, keySEL, @(ar_shouldCancelDuplicatedTask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:key];
    }
}

- (NSString *)ar_taskID {
    return objc_getAssociatedObject(self, @selector(ar_taskID));
}

- (void)setAr_taskID:(NSString *)ar_taskID {
    if (ar_taskID != self.ar_taskID) {
        SEL keySEL = @selector(ar_taskID);
        NSString *key = NSStringFromSelector(keySEL);
        [self willChangeValueForKey:key];
        objc_setAssociatedObject(self, keySEL, ar_taskID, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self didChangeValueForKey:key];
    }
}

@end
