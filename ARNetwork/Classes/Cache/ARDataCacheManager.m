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
@property (nonatomic, strong) RLMRealmConfiguration *defaultConfig;
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

- (instancetype)init {
    if (self = [super init]) {
        self.onlyAccessibleWhenUnlocked = NO;
    }
    return self;
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
        RLMRealmConfiguration *config = self.defaultConfig;
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
                [ARDataCacheManager defaultRealm];
            } else {
                key = [self addEncryptionKey];
                NSURL *tempUrl = [config.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:@"temp.realm"];
                BOOL res;
                @autoreleasepool {
                    res = [[ARDataCacheManager defaultRealm] writeCopyToURL:tempUrl encryptionKey:key error:nil];
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
                    res = [[ARDataCacheManager defaultRealm] writeCopyToURL:tempUrl encryptionKey:nil error:nil];
                }
                if (res) {
                    if ([[NSFileManager defaultManager] removeItemAtURL:config.fileURL error:nil]) {
                        config.encryptionKey = nil;
                        
                        if ([[NSFileManager defaultManager] copyItemAtURL:tempUrl toURL:config.fileURL error:nil]) {
                            [[NSFileManager defaultManager] removeItemAtURL:tempUrl error:nil];
                        }
                    }
                }
            } else {
                [ARDataCacheManager defaultRealm];
            }
        }
        
        ARLogInfo(@"Realm: %@", [ARDataCacheManager defaultRealm].configuration.fileURL);
    }
}

- (void)allClear {
    @autoreleasepool {
        RLMRealm *realm = [ARDataCacheManager defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    }
}

+ (RLMRealm *)defaultRealm {
    NSError *error = nil;
    ARDataCacheManager *manager = [ARDataCacheManager sharedInstance];
    RLMRealm *realm = [RLMRealm realmWithConfiguration:manager.defaultConfig error:&error];
    if (error) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray<NSString *> *paths = [fm contentsOfDirectoryAtPath:manager.defaultConfig.fileURL.URLByDeletingLastPathComponent.path error:nil];
        for (NSString *path in paths) {
            [fm removeItemAtURL:[manager.defaultConfig.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:path] error:nil];
        }
        
        realm = [RLMRealm realmWithConfiguration:manager.defaultConfig error:&error];
    }
    return realm;
}

#pragma mark -

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
                            (__bridge id)kSecValueData: keyData,
                            (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked};
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    NSAssert(status == errSecSuccess, @"[ARNetwork] Failed to insert new key in the keychain");
    return keyData;
}

- (void)deleteEncryptionKey {
    NSData *tag = [[self keychainId] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag};
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    NSAssert(status == errSecSuccess, @"[ARNetwork] Failed to delete the invalid key in the keychain");
}

- (NSString *)keychainId {
    return [NSString stringWithFormat:@"%@.arnetwork.datacache", [[NSBundle mainBundle] bundleIdentifier]];
}

- (RLMRealmConfiguration *)defaultConfig {
    if (_defaultConfig) {
        return _defaultConfig;
    }
    _defaultConfig = [RLMRealmConfiguration defaultConfiguration];
    _defaultConfig.fileURL = [_defaultConfig.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:[ARNetworkDomain stringByAppendingPathComponent:@"DataCache"]];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:_defaultConfig.fileURL withIntermediateDirectories:YES attributes:nil error:&error];
    NSAssert(!error, @"[ARNetwork] Failed to create default directory of data cache\n%@", error);
    _defaultConfig.fileURL = [_defaultConfig.fileURL URLByAppendingPathComponent:@"default.realm"];
    return _defaultConfig;
}

- (void)setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked {
    _onlyAccessibleWhenUnlocked = onlyAccessibleWhenUnlocked;
    
    NSFileProtectionType protection = onlyAccessibleWhenUnlocked ? NSFileProtectionComplete : NSFileProtectionCompleteUntilFirstUserAuthentication;
    NSString *folderPath = self.defaultConfig.fileURL.URLByDeletingLastPathComponent.path;
    BOOL res = [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: protection} ofItemAtPath:folderPath error:nil];
}

@end
