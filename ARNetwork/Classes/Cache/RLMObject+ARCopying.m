//
//  RLMObject+ARCopying.m
//  ARNetwork
//
//  Created by Daniel Lin on 15/11/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.

#import "RLMObject+ARCopying.h"

@interface RLMProperty (ARCopying_Internal)

@property (nonatomic, assign) BOOL isPrimary;

@end

@implementation RLMObject (ARCopying)

- (instancetype)ar_shallowCopy {
    id object = [[NSClassFromString(self.objectSchema.className) alloc] init];
    [object ar_mergePropertiesFromObject:self];
    
    return object;
}

- (void)ar_mergePropertiesFromObject:(id)object {
    
    BOOL primaryKeyIsEmpty;
    id value;
    id selfValue;
    
    BOOL (^valuesAreEqual)(id, id) = ^BOOL(id value1, id value2) {
        return ([[NSString stringWithFormat:@"%@", value1]
                 isEqualToString:[NSString stringWithFormat:@"%@", value2]]);
    };
    
    for (RLMProperty *property in self.objectSchema.properties) {
        
        if (!property.array) {
            
            // asume data
            value = [object valueForKeyPath:property.name];
            selfValue = [self valueForKeyPath:property.name];
            
            primaryKeyIsEmpty = (property.isPrimary &&
                                 !valuesAreEqual(value, selfValue)
                                 );
            
            if (primaryKeyIsEmpty || !property.isPrimary) {
                [self setValue:value forKeyPath:property.name];
            }
            
        } else {
            // asume array
            RLMArray *thisArray = [self valueForKeyPath:property.name];
            RLMArray *thatArray = [object valueForKeyPath:property.name];
            [thisArray addObjects:thatArray];
        }
    }
}


- (instancetype)ar_deepCopy {
    RLMObject *object = [[NSClassFromString(self.objectSchema.className) alloc] init];
    
    for (RLMProperty *property in self.objectSchema.properties) {
        
        if (property.array) {
            RLMArray *thisArray = [self valueForKeyPath:property.name];
            RLMArray *newArray = [object valueForKeyPath:property.name];
            
            for (RLMObject *currentObject in thisArray) {
                [newArray addObject:[currentObject ar_deepCopy]];
            }
            
        }
        else if (property.type == RLMPropertyTypeObject) {
            RLMObject *value = [self valueForKeyPath:property.name];
            [object setValue:[value ar_deepCopy] forKeyPath:property.name];
        }
        else {
            id value = [self valueForKeyPath:property.name];
            [object setValue:value forKeyPath:property.name];
        }
    }
    
    return object;
}

@end
