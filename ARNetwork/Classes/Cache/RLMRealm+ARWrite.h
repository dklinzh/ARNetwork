//
//  RLMRealm+ARWrite.h
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/29.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import <Realm/Realm.h>

@interface RLMRealm (ARWrite)

- (void)ar_cascadeDeleteObjcet:(RLMObject *)object;

- (void)ar_cascadeDeleteObjcets:(id<NSFastEnumeration>)objects;

@end
