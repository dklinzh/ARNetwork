//
//  NSObject+ARSwizzling.h
//  ARNetwork
//
//  Created by Linzh on 1/22/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef IMP *IMPPointer;

@interface NSObject (ARSwizzling)

+ (BOOL)ar_swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store;
@end
