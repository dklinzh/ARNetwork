    //
//  ARDataCacheManager.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An manager for maintaining the cache data in local database.
 */
@interface ARDataCacheManager : NSObject

/**
 The global expired interval of the all data caches to check whether the caches are expired when they are read. Defaults to 0 s.
 */
@property (nonatomic, assign) NSTimeInterval expiredInterval;

/**
 Determine whether the data from local database can only be accessed when the device is on unlocked status. Defaults to FALSE.
 */
@property (nonatomic, assign) BOOL onlyAccessibleWhenUnlocked;

@property (nonatomic, assign) BOOL readOnly;

// FIXME: ARResponseCacheModel
+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)new NS_UNAVAILABLE;

- (instancetype)initDefaultSchemaWithVersion:(NSUInteger)version;

- (instancetype)initDefaultSchemaWithVersion:(NSUInteger)version dataEncryption:(BOOL)enabled;

- (instancetype)initSchemaWithName:(NSString *)name version:(NSUInteger)version;

- (instancetype)initSchemaWithName:(NSString *)name version:(NSUInteger)version dataEncryption:(BOOL)enabled;

- (void)registerDataCacheModels:(NSArray<Class> *)classes;

/**
 Clear all of the data cache.
 */
- (void)allClear;

@end
 
NS_ASSUME_NONNULL_END
