//
//  RLMObject+ARCopying.h
//  ARNetwork
//
//  Created by Daniel Lin on 15/11/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLMObject (ARCopying)

- (instancetype)ar_shallowCopy;

- (instancetype)ar_deepCopy;

- (void)ar_mergePropertiesFromObject:(id)object;

@end

NS_ASSUME_NONNULL_END
