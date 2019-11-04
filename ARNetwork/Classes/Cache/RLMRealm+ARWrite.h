//
//  RLMRealm+ARWrite.h
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/29.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLMRealm (ARWrite)

- (void)ar_cascadeDeleteObjcet:(RLMObject *)object;

- (void)ar_cascadeDeleteObjcets:(NSObject<NSFastEnumeration> *)objects;

- (void)ar_cascadeDeleteObjcet:(RLMObject *)object
           isPrimaryKeySkipped:(BOOL)isPrimaryKeySkipped;

- (void)ar_cascadeDeleteObjcets:(NSObject<NSFastEnumeration> *)objects
            isPrimaryKeySkipped:(BOOL)isPrimaryKeySkipped;

@end

NS_ASSUME_NONNULL_END
