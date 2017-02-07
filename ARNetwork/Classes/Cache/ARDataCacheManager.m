//
//  ARDataCacheManager.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheManager.h"
#import <Realm/Realm.h>

@interface ARDataCacheManager ()

@end

@implementation ARDataCacheManager
static ARDataCacheManager *sharedInstance = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initConfigurationWithSchemaVersion:(uint64_t)version {
    [self initConfigurationWithSchemaVersion:version dataEncryption:NO];
}

- (void)initConfigurationWithSchemaVersion:(uint64_t)version dataEncryption:(BOOL)enabled {
    @autoreleasepool {
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.schemaVersion = version;
        config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
            if (oldSchemaVersion < version) {
                
            }
        };
        
        // Encryption Switch
        if (enabled) {
            NSData *key = [self searchEncryptionKey];
            if (key) {
                config.encryptionKey = key;
            } else {
                key = [self addEncryptionKey];
                NSURL *tempUrl = [config.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:@"temp.realm"];
                BOOL res;
                @autoreleasepool {
                    res = [[RLMRealm realmWithConfiguration:config error:nil] writeCopyToURL:tempUrl encryptionKey:key error:nil];
                }
                if (res) {
                    if ([[NSFileManager defaultManager] removeItemAtURL:config.fileURL error:nil]) {
                        config.encryptionKey = key;
                        
                        if ([[NSFileManager defaultManager] copyItemAtURL:tempUrl toURL:config.fileURL error:nil]) {
                            [[NSFileManager defaultManager] removeItemAtURL:tempUrl error:nil];
                        }
                    }
                }
            }
        } else {
            NSData *key = [self searchEncryptionKey];
            if (key) {
                [self deleteEncryptionKey];
                NSURL *tempUrl = [config.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:@"temp.realm"];
                BOOL res;
                @autoreleasepool {
                    config.encryptionKey = key;
                    res = [[RLMRealm realmWithConfiguration:config error:nil] writeCopyToURL:tempUrl encryptionKey:nil error:nil];
                }
                if (res) {
                    if ([[NSFileManager defaultManager] removeItemAtURL:config.fileURL error:nil]) {
                        config.encryptionKey = nil;
                        
                        if ([[NSFileManager defaultManager] copyItemAtURL:tempUrl toURL:config.fileURL error:nil]) {
                            [[NSFileManager defaultManager] removeItemAtURL:tempUrl error:nil];
                        }
                    }
                }
            }
        }
        
        [RLMRealmConfiguration setDefaultConfiguration:config];
    }
    
    ARLogInfo(@"Realm: %@", [RLMRealm defaultRealm].configuration.fileURL);
}

- (void)allClear {
    @autoreleasepool {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    }
}

- (NSData *)searchEncryptionKey {
    NSData *tag = [[self keychainId] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecReturnData: @YES};
    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef);
    if (status == errSecSuccess) {
        NSData *keyData = (__bridge NSData *)dataRef;
        CFRelease(dataRef);
        return keyData;
    } else {
        return nil;
    }
}

- (NSData *)addEncryptionKey {
    uint8_t buffer[64];
    OSStatus status = SecRandomCopyBytes(kSecRandomDefault, 64, buffer);
    NSAssert(status == errSecSuccess, @"[ARNetwork] Failed to generate random bytes for key");
    NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
    NSData *tag = [[self keychainId] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrApplicationTag: tag,
              (__bridge id)kSecAttrKeySizeInBits: @512,
              (__bridge id)kSecValueData: keyData};
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    NSAssert(status == errSecSuccess, @"[ARNetwork] Failed to insert new key in the keychain");
    return keyData;
}

- (void)deleteEncryptionKey {
    NSData *tag = [[self keychainId] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512};
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    NSAssert(status == errSecSuccess, @"[ARNetwork] Failed to delete the invalid key in the keychain");
}

- (NSString *)keychainId {
    return [NSString stringWithFormat:@"%@.arnetwork.datacache", [[NSBundle mainBundle] bundleIdentifier]];
}

@end
