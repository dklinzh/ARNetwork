    //
//  ARDataCacheManager.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARDataCacheModel.h"

@class ARHTTPManager;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ARDataCacheMigrationBlock)(RLMMigration *migration, uint64_t oldVersion, uint64_t currentVersion);

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
@property (nonatomic, assign, getter=isOnlyAccessibleWhenUnlocked) BOOL onlyAccessibleWhenUnlocked;

@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;

/**
 When all in-memory Realm instances with a particular identifier go out of scope with no references, all data in that Realm is deleted. We recommend holding onto a strong reference to any in-memory Realms during your app’s lifetime. (This is not necessary for on-disk Realms.)
 */
@property (nonatomic, assign, getter=isMemoryOnly) BOOL memoryOnly;

@property (nonatomic, strong) ARHTTPManager *httpManager;

// FIXME: ARResponseCacheModel
+ (instancetype)sharedInstance __attribute__ ((deprecated));

- (instancetype)initWithVersion:(uint64_t)version;

- (instancetype)initWithVersion:(uint64_t)version encryption:(BOOL)enabled;

- (instancetype)initWithSchema:(NSString *)schemaName version:(uint64_t)version;

- (instancetype)initWithSchema:(NSString *)schemaName version:(uint64_t)version encryption:(BOOL)enabled NS_DESIGNATED_INITIALIZER;

/**
 Set the block which migrates the data caches to the current version. Should be invoked before invoking -[ARDataCacheManager registerModels:].

 @param block The block which migrates the data caches to the current version
 */
- (void)setDataCacheMigration:(ARDataCacheMigrationBlock)block;

- (void)registerModels:(nullable NSArray<Class> *)classes;

/**
 Clear all of the data cache.
 */
- (void)clearAllDataCaches;

@end

@interface ARDataCacheManager (Unavailable)
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
@end
 
NS_ASSUME_NONNULL_END
