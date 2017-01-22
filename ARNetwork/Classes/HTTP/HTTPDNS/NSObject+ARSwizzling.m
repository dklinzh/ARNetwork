//
//  NSObject+ARSwizzling.m
//  ARNetwork
//
//  Created by Linzh on 1/22/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "NSObject+ARSwizzling.h"
#import <objc/runtime.h>

@implementation NSObject (ARSwizzling)

+ (BOOL)ar_swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store {
    return class_swizzleMethodAndStore(self, original, replacement, store);
}

BOOL class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, original);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    if (imp && store) {
        *store = imp;
    }
    return (imp != NULL);
}
@end
