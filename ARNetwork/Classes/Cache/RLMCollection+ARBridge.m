//
//  RLMCollection+ARBridge.m
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "RLMCollection+ARBridge.h"

@implementation RLMArray (ARBridge)

- (NSArray *)ar_primitiveArray {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *item in self) {
        [array addObject:item];
    }
    return [array copy];
}

@end

@implementation RLMResults (ARBridge)

- (NSArray *)ar_primitiveArray {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *item in self) {
        [array addObject:item];
    }
    return [array copy];
}

@end
