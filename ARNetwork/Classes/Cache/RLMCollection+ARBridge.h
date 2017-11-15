//
//  RLMCollection+ARBridge.h
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLMArray<RLMObjectType> (ARBridge)

- (NSArray<RLMObjectType> *)ar_primitiveArray;

@end

@interface RLMResults<RLMObjectType> (ARBridge)

- (NSArray<RLMObjectType> *)ar_primitiveArray;

@end

NS_ASSUME_NONNULL_END
