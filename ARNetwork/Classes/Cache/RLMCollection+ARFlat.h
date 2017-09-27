//
//  RLMCollection+ARFlat.h
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLMArray<RLMObjectType: RLMObject *> (ARFlat)

- (NSArray *)ar_flatArray;

@end

@interface RLMResults<RLMObjectType: RLMObject *> (ARFlat)

- (NSArray *)ar_flatArray;

@end

NS_ASSUME_NONNULL_END
