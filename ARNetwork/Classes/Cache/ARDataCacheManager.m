//
//  ARDataCacheManager.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheManager.h"
#import "ARDataCacheModel.h"
#import "_ARResponseCacheModel.h"
#import "ARHTTPManager.h"

static NSString *const kDefaultSchemaName = @"default";

@interface ARDataCacheManager ()
@property (nonatomic, strong) RLMRealmConfiguration *defaultConfig;
@property (nonatomic, copy) NSString *schemaName;
@property (nonatomic, strong) NSURL *defaultFileURL;
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

- (RLMRealm *)defaultRealm {
    NSError *error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:self.defaultConfig error:&error];
    if (error) {
        ARLogWarn(@"defaultRealm: %@", error);
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray<NSString *> *paths = [fm contentsOfDirectoryAtPath:self.defaultConfig.fileURL.URLByDeletingLastPathComponent.path error:nil];
        for (NSString *path in paths) {
            [fm removeItemAtURL:[self.defaultConfig.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:path] error:nil];
        }
        
        realm = [RLMRealm realmWithConfiguration:self.defaultConfig error:&error];
    }
    return realm;
}

- (RLMRealmConfiguration *)defaultConfig {
    if (_defaultConfig) {
        return _defaultConfig;
    }
    
    _defaultConfig = [RLMRealmConfiguration defaultConfiguration];
    _defaultConfig.fileURL = self.defaultFileURL;
    return _defaultConfig;
}

- (NSURL *)defaultFileURL {
    if (_defaultFileURL) {
        return _defaultFileURL;
    }
    
    NSURL *fileURL = [[RLMRealmConfiguration defaultConfiguration].fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:[ARNetworkDomain stringByAppendingPathComponent:[NSString stringWithFormat:@"DataCache/%@.schema", self.schemaName]]];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:fileURL withIntermediateDirectories:YES attributes:nil error:&error];
    NSAssert(!error, @"[ARNetwork] ⚠️ Failed to create default directory of data cache\n%@", error);
    return _defaultFileURL = [fileURL URLByAppendingPathComponent:@"data.ar.realm"];
}

- (void)allClear {
    @autoreleasepool {
        RLMRealm *realm = [self defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    }
}

#pragma mark -

- (void)setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked {
    _onlyAccessibleWhenUnlocked = onlyAccessibleWhenUnlocked;
    
    NSFileProtectionType protection = onlyAccessibleWhenUnlocked ? NSFileProtectionComplete : NSFileProtectionCompleteUntilFirstUserAuthentication;
    NSString *folderPath = self.defaultConfig.fileURL.URLByDeletingLastPathComponent.path;
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: protection} ofItemAtPath:folderPath error:nil];
}

- (void)setReadOnly:(BOOL)readOnly {
    _readOnly = readOnly;
    
    self.defaultConfig.readOnly = readOnly;
}

- (void)setMemoryOnly:(BOOL)memoryOnly {
    if (_memoryOnly == memoryOnly) {
        return;
    }
    
    _memoryOnly = memoryOnly;
    if (memoryOnly) {
        self.defaultConfig.inMemoryIdentifier = ar_dataCacheID(self.schemaName);
    } else {
        self.defaultConfig.fileURL = self.defaultFileURL;
    }
}

- (ARHTTPManager *)httpManager {
    if (_httpManager) {
        return _httpManager;
    }
    
    return _httpManager = [ARHTTPManager manager];
}

#pragma mark - Schema Register

static NSMutableDictionary<NSString *, ARDataCacheManager *> * ar_schemaManagers() {
    static NSMutableDictionary<NSString *, ARDataCacheManager *> *arSchemaManagers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arSchemaManagers = [NSMutableDictionary dictionary];
    });
    return arSchemaManagers;
}

- (void)registerDataCacheModels:(NSArray<Class> *)classes {
    NSMutableArray *objectClasses = [NSMutableArray arrayWithArray:classes];
    [objectClasses addObject:ARWrapedString.class];
    self.defaultConfig.objectClasses = objectClasses;
    
    for (Class clazz in classes) {
        if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
            [ar_schemaManagers() setValue:self forKey:NSStringFromClass(clazz)];
        }
    }
}

+ (instancetype)_managerWithModelClass:(Class)clazz {
    NSArray *keys = [NSStringFromClass(clazz) componentsSeparatedByString:@" "];
    ARDataCacheManager *manager = [ar_schemaManagers() valueForKey:keys.lastObject];
    NSAssert(manager, @"[ARNetwork] ⚠️ Class `%@` has not been registered in a schema.", NSStringFromClass(clazz));
    return manager;
}

+ (RLMRealm *)_realmWithModelClass:(Class)clazz {
    return [[self _managerWithModelClass:clazz] defaultRealm];
}

+ (instancetype)sharedInstance {
    static ARDataCacheManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ARDataCacheManager alloc] initSchemaWithName:@"" version:0 dataEncryption:true];
        [sharedInstance registerDataCacheModels:@[_ARResponseCacheModel.class]];
    });
    return sharedInstance;
}

#pragma mark -

- (void)configureWithSchemaVersion:(uint64_t)version dataEncryption:(BOOL)enabled {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            RLMRealmConfiguration *config = self.defaultConfig;
            config.schemaVersion = version;
            config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
                if (oldSchemaVersion < version) {
                    // Migrations
                }
            };
            config.shouldCompactOnLaunch = ^BOOL(NSUInteger totalBytes, NSUInteger bytesUsed) {
                NSUInteger compatingSize = 100 * 1024 * 1024;
                double usedPercent = (double)bytesUsed / totalBytes;
                ARLogInfo(@"Schema: `%@` - Total: %f MB, Used: %f %%", self.schemaName, (double)totalBytes / (1024 * 1024), usedPercent * 100);
                return (totalBytes > compatingSize) && usedPercent < 0.5;
            };
            
            // Encryption Switch
            if (enabled) {
                NSData *key = [self searchEncryptionKey];
                if (key) {
                    config.encryptionKey = key;
                    [self defaultRealm];
                } else {
                    key = [self addEncryptionKey];
                    NSURL *tempUrl = ar_realmTempFileURL(self.defaultConfig.fileURL);
                    BOOL result = [[self defaultRealm] writeCopyToURL:tempUrl encryptionKey:key error:nil];
                    if (result) {
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
                    NSURL *tempUrl = ar_realmTempFileURL(self.defaultConfig.fileURL);
                    config.encryptionKey = key;
                    BOOL result = [[self defaultRealm] writeCopyToURL:tempUrl encryptionKey:nil error:nil];
                    if (result) {
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
    });
}

- (NSData *)searchEncryptionKey {
    NSData *tag = [ar_dataCacheID(self.schemaName) dataUsingEncoding:NSUTF8StringEncoding];
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
    NSAssert(status == errSecSuccess, @"[ARNetwork] ⚠️ Failed to generate random bytes for key");
    NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
    NSData *tag = [ar_dataCacheID(self.schemaName) dataUsingEncoding:NSUTF8StringEncoding];
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
    NSData *tag = [ar_dataCacheID(self.schemaName) dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag};
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    NSAssert(status == errSecSuccess, @"[ARNetwork] ⚠️ Failed to delete the invalid key in the keychain");
}

static inline NSString *ar_dataCacheID(NSString *key) {
    return [NSString stringWithFormat:@"%@.ar.datacache.%@", [[NSBundle mainBundle] bundleIdentifier], key];
}

static inline NSURL * ar_realmTempFileURL(NSURL *fileURL) {
    return [fileURL.URLByDeletingPathExtension URLByAppendingPathExtension:@".temp.realm"];
}

@end
