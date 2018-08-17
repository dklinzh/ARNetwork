    //
//  ARDataCacheManager.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARHTTPManager;

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
@property (nonatomic, assign, getter=isOnlyAccessibleWhenUnlocked) BOOL onlyAccessibleWhenUnlocked;

@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;

/**
 When all in-memory Realm instances with a particular identifier go out of scope with no references, all data in that Realm is deleted. We recommend holding onto a strong reference to any in-memory Realms during your app’s lifetime. (This is not necessary for on-disk Realms.)
 */
@property (nonatomic, assign, getter=isMemoryOnly) BOOL memoryOnly;

@property (nonatomic, strong) ARHTTPManager *httpManager;

// FIXME: ARResponseCacheModel
+ (instancetype)sharedInstance __attribute__ ((deprecated));

- (instancetype)initWithVersion:(NSUInteger)version;

- (instancetype)initWithVersion:(NSUInteger)version encryption:(BOOL)enabled;

- (instancetype)initWithSchema:(NSString *)schemaName version:(NSUInteger)version;

- (instancetype)initWithSchema:(NSString *)schemaName version:(NSUInteger)version encryption:(BOOL)enabled NS_DESIGNATED_INITIALIZER;

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
