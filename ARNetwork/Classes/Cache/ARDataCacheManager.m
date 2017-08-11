//
//  ARDataCacheManager.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheManager.h"
#import "NSString+ARSHA1.h"
#import "ARDataCacheModel.h"
#import "ARResponseCacheModel.h"

static NSString *const kDefaultSchemaName = @"default";

@interface ARDataCacheManager ()
@property (nonatomic, strong) RLMRealmConfiguration *defaultConfig;
@property (nonatomic, copy) NSString *schemaName;

@end

@implementation ARDataCacheManager

- (instancetype)initDefaultSchemaWithVersion:(NSUInteger)version {
    return [self initDefaultSchemaWithVersion:version dataEncryption:NO];
}

- (instancetype)initDefaultSchemaWithVersion:(NSUInteger)version dataEncryption:(BOOL)enabled {
    return [self initSchemaWithName:kDefaultSchemaName version:version dataEncryption:enabled];
}

- (instancetype)initSchemaWithName:(NSString *)name version:(NSUInteger)version {
    return [self initSchemaWithName:name version:version dataEncryption:NO];
}

- (instancetype)initSchemaWithName:(NSString *)name version:(NSUInteger)version dataEncryption:(BOOL)enabled {
    if (self = [super init]) {
        self.schemaName = name;
        self.onlyAccessibleWhenUnlocked = NO;
        
        [self configureWithSchemaVersion:version dataEncryption:enabled];
        
    }
    return self;
}

- (void)allClear {
    @autoreleasepool {
        RLMRealm *realm = [self defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    }
}

- (RLMRealm *)defaultRealm {
    NSError *error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:self.defaultConfig error:&error];
    if (error) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray<NSString *> *paths = [fm contentsOfDirectoryAtPath:self.defaultConfig.fileURL.URLByDeletingLastPathComponent.path error:nil];
        for (NSString *path in paths) {
            [fm removeItemAtURL:[self.defaultConfig.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:path] error:nil];
        }
        
        realm = [RLMRealm realmWithConfiguration:self.defaultConfig error:&error];
    }
    return realm;
}

#pragma mark - Schema Register

- (void)registerDataCacheModels:(NSArray<Class> *)classes {
    for (Class clazz in classes) {
        if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
            [[self.class arSchemaManagers] setValue:self forKey:NSStringFromClass(clazz)];
        }
    }
}

+ (NSMutableDictionary *)arSchemaManagers {
    static NSMutableDictionary *arSchemaManagers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arSchemaManagers = [NSMutableDictionary dictionary];
    });
    return arSchemaManagers;
}

+ (instancetype)ar_managerWithModelClass:(Class)clazz {
    NSArray *keys = [NSStringFromClass(clazz) componentsSeparatedByString:@" "];
    ARDataCacheManager *manager = [[self.class arSchemaManagers] valueForKey:keys.lastObject];
    NSAssert(manager, @"[ARNetwork] ⚠️ Class `%@` has not been registered in a schema.", NSStringFromClass(clazz));
    return manager;
}

+ (RLMRealm *)ar_realmWithModelClass:(Class)clazz {
    return [[self ar_managerWithModelClass:clazz] defaultRealm];
}

+ (NSString *)ar_primaryKeyWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    NSURL *url = [NSURL URLWithString:urlStr];
    return [[NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description] ar_SHA1];
}

+ (instancetype)sharedInstance {
    static ARDataCacheManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ARDataCacheManager alloc] initSchemaWithName:@"" version:0 dataEncryption:true];
        [sharedInstance registerDataCacheModels:@[ARResponseCacheModel.class]];
    });
    return sharedInstance;
}

#pragma mark -

- (void)configureWithSchemaVersion:(uint64_t)version dataEncryption:(BOOL)enabled {
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
                [self defaultRealm];
            } else {
                key = [self addEncryptionKey];
                NSURL *tempUrl = [self tempFileURL];
                BOOL res;
                @autoreleasepool {
                    res = [[self defaultRealm] writeCopyToURL:tempUrl encryptionKey:key error:nil];
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
                NSURL *tempUrl = [self tempFileURL];
                BOOL res;
                @autoreleasepool {
                    config.encryptionKey = key;
                    res = [[self defaultRealm] writeCopyToURL:tempUrl encryptionKey:nil error:nil];
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
                [self defaultRealm];
            }
        }
        
        ARLogInfo(@"Realm: %@", [self defaultRealm].configuration.fileURL);
    }
}

- (NSData *)searchEncryptionKey {
    NSData *tag = [[self keychainID] dataUsingEncoding:NSUTF8StringEncoding];
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
    NSData *tag = [[self keychainID] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecValueData: keyData,
                            (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked};
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    NSAssert(status == errSecSuccess, @"[ARNetwork] ⚠️ Failed to insert new key in the keychain");
    return keyData;
}

- (void)deleteEncryptionKey {
    NSData *tag = [[self keychainID] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag};
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    NSAssert(status == errSecSuccess, @"[ARNetwork] ⚠️ Failed to delete the invalid key in the keychain");
}

- (NSString *)keychainID {
    return [NSString stringWithFormat:@"%@.arnetwork.datacache.%@", [[NSBundle mainBundle] bundleIdentifier], self.schemaName];
}

- (RLMRealmConfiguration *)defaultConfig {
    if (_defaultConfig) {
        return _defaultConfig;
    }
    _defaultConfig = [RLMRealmConfiguration defaultConfiguration];
    _defaultConfig.fileURL = [_defaultConfig.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:[ARNetworkDomain stringByAppendingPathComponent:[NSString stringWithFormat:@"DataCache/%@.schema", self.schemaName]]];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:_defaultConfig.fileURL withIntermediateDirectories:YES attributes:nil error:&error];
    NSAssert(!error, @"[ARNetwork] ⚠️ Failed to create default directory of data cache\n%@", error);
    _defaultConfig.fileURL = [_defaultConfig.fileURL URLByAppendingPathComponent:@"data.ar.realm"];
    return _defaultConfig;
}

- (NSURL *)tempFileURL {
    return [self.defaultConfig.fileURL.URLByDeletingPathExtension URLByAppendingPathExtension:@".temp.realm"];
}

- (void)setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked {
    _onlyAccessibleWhenUnlocked = onlyAccessibleWhenUnlocked;
    
    NSFileProtectionType protection = onlyAccessibleWhenUnlocked ? NSFileProtectionComplete : NSFileProtectionCompleteUntilFirstUserAuthentication;
    NSString *folderPath = self.defaultConfig.fileURL.URLByDeletingLastPathComponent.path;
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: protection} ofItemAtPath:folderPath error:nil];
}

@end
