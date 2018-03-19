//
//  _NSObject+ARProperty.h
//  ARNetwork
//
//  Created by Daniel Lin on 19/03/2018.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ARProperty)
/**
 *  Add a property of id type, a strong reference to the associated object.
 *
 *  @param name property name
 */
+ (void)_addObjectProperty:(NSString *)name;

/**
 *  Add a property of type id with objc_AssociationPolicy.
 *
 *  @param name   property name
 *  @param policy Policies related to associative references.
 */
+ (void)_addObjectProperty:(NSString *)name associationPolicy:(objc_AssociationPolicy)policy;

/**
 *  Add a property of basic type, e.g. int, float, BOOL, CGRect etc.
 *
 *  @param name property name
 *  @param type encodingType of property. e.g. @‎encode(int)
 */
+ (void)_addBasicProperty:(NSString *)name encodingType:(char *)type;

@end

NS_ASSUME_NONNULL_END
