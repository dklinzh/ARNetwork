//
//  RLMCollection+ARBridge.m
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "RLMCollection+ARBridge.h"

@implementation RLMArray (ARBridge)

- (BOOL)isEmpty {
    return self.count == 0;
}

- (NSArray *)ar_primitiveArray {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *item in self) {
        [array addObject:item];
    }
    return [array copy];
}

- (void)ar_setValue:(id)value forKeyPath:(NSString *)keyPath {
    if (self.count == 0 || self.invalidated || self.type != RLMPropertyTypeObject) {
        return;
    }
    
    [self.realm beginWriteTransaction];
    [self setValue:value forKeyPath:keyPath];
    [self.realm commitWriteTransaction];
}

@end

@implementation RLMResults (ARBridge)

- (BOOL)isEmpty {
    return self.count == 0;
}

- (NSArray *)ar_primitiveArray {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *item in self) {
        [array addObject:item];
    }
    return [array copy];
}

- (void)ar_setValue:(id)value forKeyPath:(NSString *)keyPath {
    if (self.count == 0 || self.invalidated || self.type != RLMPropertyTypeObject) {
        return;
    }
    
    [self.realm beginWriteTransaction];
    [self setValue:value forKeyPath:keyPath];
    [self.realm commitWriteTransaction];
}

@end
