//
//  RLMCollection+ARFlat.h
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMArray<RLMObjectType: RLMObject *> (ARFlat)

- (NSArray *)ar_flatArray;

@end

@interface RLMResults<RLMObjectType: RLMObject *> (ARFlat)

- (NSArray *)ar_flatArray;

@end
