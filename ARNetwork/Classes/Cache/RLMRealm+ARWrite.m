//
//  RLMRealm+ARWrite.m
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/29.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import "RLMRealm+ARWrite.h"

@implementation RLMRealm (ARWrite)

- (void)ar_cascadeDeleteObjcets:(NSObject<NSFastEnumeration> *)objects {
    [self ar_cascadeDeleteObjcets:objects isPrimaryKeyObjectSkipped:NO];
}

- (void)ar_cascadeDeleteObjcet:(RLMObject *)object {
    [self ar_cascadeDeleteObjcet:object isPrimaryKeySkipped:NO];
}

- (void)ar_cascadeDeleteObjcets:(NSObject<NSFastEnumeration> *)objects
      isPrimaryKeyObjectSkipped:(BOOL)isPrimaryKeyObjectSkipped {
    if (isPrimaryKeyObjectSkipped && [objects isKindOfClass:RLMArray.class]) {
        RLMArray *rlmArray = (RLMArray *)objects;
        if (rlmArray.type == RLMPropertyTypeObject && [NSClassFromString(rlmArray.objectClassName) primaryKey]) {
            [rlmArray removeAllObjects];
            return;
        }
    }
    
    for (id object in objects) {
        if ([object isKindOfClass:RLMObject.class]) {
            [self ar_cascadeDeleteObjcet:object isPrimaryKeySkipped:isPrimaryKeyObjectSkipped];
        }
    }
}

- (void)ar_cascadeDeleteObjcet:(RLMObject *)object
           isPrimaryKeySkipped:(BOOL)isPrimaryKeySkipped {
    NSMutableOrderedSet<RLMObject *> *deletedObjects = [NSMutableOrderedSet orderedSet];
    [deletedObjects addObject:object];
    while (deletedObjects.count > 0) {
        RLMObject *element = deletedObjects.firstObject;
        [deletedObjects removeObjectAtIndex:0];
        
        if (!element.isInvalidated) {
            ARDeletedObjectsResolve(self, element, deletedObjects, isPrimaryKeySkipped);
        }
    }
}

static inline void ARDeletedObjectsResolve(RLMRealm *realm,
                                           RLMObject *element,
                                           NSMutableOrderedSet<RLMObject *> *deletedObjects,
                                           BOOL isPrimaryKeySkipped) {
    if (isPrimaryKeySkipped && [element.class primaryKey]) {
        return;
    }
    
    NSArray<RLMProperty *> *properties = element.objectSchema.properties;
    for (RLMProperty *property in properties) {
        id value = [element valueForKey:property.name];
        if (!value) {
            continue;
        }
        
        if ([value isKindOfClass:RLMObject.class]) {
            if (isPrimaryKeySkipped && [[value class] primaryKey]) {
                [element setValue:nil forKey:property.name];
                continue;
            }
            
            [deletedObjects addObject:value];
        } else if ([value isKindOfClass:RLMArray.class]) {
            RLMArray *rlmArray = (RLMArray *)value;
            if (rlmArray.type == RLMPropertyTypeObject) {
                if (isPrimaryKeySkipped && [NSClassFromString(rlmArray.objectClassName) primaryKey]) {
                    [rlmArray removeAllObjects];
                    continue;
                }
                
                for (id object in rlmArray) {
                    [deletedObjects addObject:object];
                }
            }
        }
    }
    
    [realm deleteObject:element];
}

@end
