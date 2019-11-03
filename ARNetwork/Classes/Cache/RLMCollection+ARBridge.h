//
//  RLMCollection+ARBridge.h
//  ARNetwork
//
//  Created by Daniel Lin on 04/08/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ARCollectionBridge <NSFastEnumeration>

@property (nonatomic, assign, readonly) BOOL isEmpty;

- (NSArray *)ar_primitiveArray;

- (void)ar_setValue:(nullable id)value forKeyPath:(NSString *)keyPath;

@end

@interface RLMArray<RLMObjectType> (ARBridge) <ARCollectionBridge>
- (NSArray<RLMObjectType> *)ar_primitiveArray;
@end

@interface RLMResults<RLMObjectType> (ARBridge) <ARCollectionBridge>
- (NSArray<RLMObjectType> *)ar_primitiveArray;
@end

NS_ASSUME_NONNULL_END
