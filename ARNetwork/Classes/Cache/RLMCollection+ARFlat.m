//
//  RLMCollection+ARFlat.m
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "RLMCollection+ARFlat.h"

@implementation RLMArray (ARFlat)

- (NSArray *)ar_flatArray {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *item in self) {
        [array addObject:item];
    }
    return array;
}

@end

@implementation RLMResults (ARFlat)

- (NSArray *)ar_flatArray {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *item in self) {
        [array addObject:item];
    }
    return array;
}

@end
