    //
//  ARDataCacheManager.h
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMRealm;

@interface ARDataCacheManager : NSObject
@property (nonatomic, assign) NSTimeInterval expiredInterval;
@property (nonatomic, assign) BOOL onlyAccessibleWhenUnlocked;

+ (instancetype)sharedInstance;

+ (RLMRealm *)defaultRealm;

- (void)initConfigurationWithSchemaVersion:(uint64_t)version;

- (void)initConfigurationWithSchemaVersion:(uint64_t)version dataEncryption:(BOOL)enabled;

- (void)allClear;
@end
 
