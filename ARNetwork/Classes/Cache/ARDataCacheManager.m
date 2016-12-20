//
//  ARDataCacheManager.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheManager.h"
#import <Realm/Realm.h>

@implementation ARDataCacheManager

+ (void)initDataCacheConfigurationWithSchemaVersion:(uint64_t)version {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = version;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < version) {
            
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    ARLogInfo(@"Realm: %@", [RLMRealm defaultRealm].configuration.fileURL);
}

+ (void)clearAllDataCache {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}
@end
