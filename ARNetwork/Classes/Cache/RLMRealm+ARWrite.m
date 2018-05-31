//
//  RLMRealm+ARWrite.m
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/29.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import "RLMRealm+ARWrite.h"

@implementation RLMRealm (ARWrite)

- (void)ar_cascadeDeleteObjcets:(id<NSFastEnumeration>)objects {
    for (id object in objects) {
        if ([object isKindOfClass:RLMObject.class]) {
            [self ar_cascadeDeleteObjcet:object];
        }
    }
}

- (void)ar_cascadeDeleteObjcet:(RLMObject *)object {
    NSMutableOrderedSet<RLMObject *> *deletedObjects = [NSMutableOrderedSet orderedSet];
    [deletedObjects addObject:object];
    while (deletedObjects.count > 0) {
        RLMObject *element = deletedObjects.firstObject;
        [deletedObjects removeObjectAtIndex:0];
        
        if (!element.isInvalidated) {
            ARDeletedObjectsResolve(self, element, deletedObjects);
        }
    }
}

static inline void ARDeletedObjectsResolve(RLMRealm *realm, RLMObject *element, NSMutableOrderedSet<RLMObject *> *deletedObjects) {
    NSArray<RLMProperty *> *properties = element.objectSchema.properties;
    for (RLMProperty *property in properties) {
        id value = [element valueForKey:property.name];
        if (!value) {
            continue;
        }
        
        if ([value isKindOfClass:RLMObject.class]) {
            [deletedObjects addObject:value];
        } else if ([value isKindOfClass:RLMArray.class]) {
            RLMArray *rlmArray = (RLMArray *)value;
            if (rlmArray.type == RLMPropertyTypeObject) {
                for (id object in rlmArray) {
                    [deletedObjects addObject:object];
                }
            }
        }
    }
    
    [realm deleteObject:element];
}

@end
