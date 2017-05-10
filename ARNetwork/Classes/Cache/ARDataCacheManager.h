    //
//  ARDataCacheManager.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMRealm;

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

/**
 The singleton of class `ARDataCacheManager`.

 @return The instance of `ARDataCacheManager`
 */
+ (instancetype)sharedInstance;

/**
 The default RLMRealm object for the default database of ARNetwork framework.

 @return The default RLMRealm object for the default database of ARNetwork framework.
 */
+ (RLMRealm *)defaultRealm;


/**
 Initialize the Realm configuration before using the caches from local database.

 @param version The current schema version. The version should be upgrade when the data structure of table or database was changed.
 */
- (void)initConfigurationWithSchemaVersion:(uint64_t)version;

/**
 Initialize the Realm configuration before using the caches from local database.

 @param version The current schema version. The version should be upgrade when the data structure of table or database was changed.
 @param enabled Whether the cache data in the local database should be encrypted. Defaults to FALSE
 */
- (void)initConfigurationWithSchemaVersion:(uint64_t)version dataEncryption:(BOOL)enabled;

/**
 Clear all of the data cache.
 */
- (void)allClear;
@end
 
