//
//  ARDataCacheManager.m
//  ARNetwork
//
//  Created by Linzh on 12/14/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheManager.h"
#import "_ARResponseCacheModel.h"
#import "ARHTTPManager.h"

static NSString *const kDefaultSchemaName = @"dklinzh.arnetwork.default";

@interface ARDataCacheManager ()
@property (nonatomic, strong) RLMRealmConfiguration *defaultConfig;
@property (nonatomic, copy) NSString *schemaName;
@property (nonatomic, assign) uint64_t schemaVersion;
@property (nonatomic, assign) BOOL dataEncryption;
@property (nonatomic, strong) NSURL *defaultFileURL;
@property (nonatomic, strong) dispatch_queue_t cacheSchemaQueue;
@property (nonatomic, copy) NSArray<Class> *modelClasses;
@property (nonatomic, copy) ARDataCacheMigrationBlock migrationBlock;
@end

@implementation ARDataCacheManager

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (instancetype)init {
    return [self initWithVersion:0];
}
#pragma clang diagnostic pop

- (instancetype)initWithVersion:(uint64_t)version {
    return [self initWithVersion:version encryption:NO];
}

- (instancetype)initWithVersion:(uint64_t)version encryption:(BOOL)enabled {
    return [self initWithSchema:kDefaultSchemaName version:version encryption:enabled];
}

- (instancetype)initWithSchema:(NSString *)schemaName version:(uint64_t)version {
    return [self initWithSchema:schemaName version:version encryption:NO];
}

- (instancetype)initWithSchema:(NSString *)schemaName version:(uint64_t)version encryption:(BOOL)enabled {
    if (self = [super init]) {
        _schemaName = schemaName;
        _schemaVersion = version;
        _dataEncryption = enabled;
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
    ARAssert(!error, @"Failed to create default directory of data cache\n%@", error);
    return _defaultFileURL = [fileURL URLByAppendingPathComponent:@"data.ar.realm"];
}

- (void)clearAllDataCaches {
    [self _asyncCacheExecute:^{
        @autoreleasepool {
            RLMRealm *realm = [self defaultRealm];
            [realm beginWriteTransaction];
            [realm deleteAllObjects];
            [realm commitWriteTransaction];
        }
    }];
}

#pragma mark -

- (void)setDataCacheMigration:(ARDataCacheMigrationBlock)block {
    self.migrationBlock = block;
}

- (void)setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked {
    if (_onlyAccessibleWhenUnlocked == onlyAccessibleWhenUnlocked) {
        return;
    }
    
    _onlyAccessibleWhenUnlocked = onlyAccessibleWhenUnlocked;
    [self _setOnlyAccessibleWhenUnlocked:onlyAccessibleWhenUnlocked];
}

- (void)_setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked {
    NSFileProtectionType protection = onlyAccessibleWhenUnlocked ? NSFileProtectionComplete : NSFileProtectionCompleteUntilFirstUserAuthentication;
    NSString *folderPath = self.defaultConfig.fileURL.URLByDeletingLastPathComponent.path;
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: protection} ofItemAtPath:folderPath error:nil];
}

- (void)setReadOnly:(BOOL)readOnly {
    if (_readOnly == readOnly) {
        return;
    }
    
    _readOnly = readOnly;
    [self _setReadOnly:readOnly];
}

- (void)_setReadOnly:(BOOL)readOnly {
    self.defaultConfig.readOnly = readOnly;
}

- (void)setMemoryOnly:(BOOL)memoryOnly {
    if (_memoryOnly == memoryOnly) {
        return;
    }
    
    _memoryOnly = memoryOnly;
    [self _setMemoryOnly:memoryOnly];
}

- (void)_setMemoryOnly:(BOOL)memoryOnly {
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
        arSchemaManagers = [[NSMutableDictionary alloc] init];
    });
    return arSchemaManagers;
}

- (void)registerModels:(NSArray<Class> *)classes {
    self.modelClasses = classes;
    [self setupSchemaConfiguration:^{
        
    }];
    
    [self _registerModels:classes];
}

- (void)_registerModels:(NSArray<Class> *)classes {
    for (Class clazz in classes) {
        if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
            [ar_schemaManagers() setValue:self forKey:NSStringFromClass(clazz)];
        }
    }
}

+ (instancetype)_managerWithModelClass:(Class)clazz {
    NSArray *keys = [NSStringFromClass(clazz) componentsSeparatedByString:@" "];
    ARDataCacheManager *manager = [ar_schemaManagers() valueForKey:keys.lastObject];
    ARAssert(manager, @"Class<%@> has not been registered in a schema.", NSStringFromClass(clazz));
    return manager;
}

+ (RLMRealm *)_realmWithModelClass:(Class)clazz {
    return [[self _managerWithModelClass:clazz] defaultRealm];
}

+ (instancetype)sharedInstance {
    static ARDataCacheManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ARDataCacheManager alloc] initWithSchema:@"" version:0 encryption:true];
        [sharedInstance registerModels:@[_ARResponseCacheModel.class]];
    });
    return sharedInstance;
}

#pragma mark -
- (dispatch_queue_t)cacheSchemaQueue {
    if (_cacheSchemaQueue) {
        return _cacheSchemaQueue;
    }
    
    return _cacheSchemaQueue = dispatch_queue_create([ar_dataCacheID(self.schemaName) cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
}

- (void)_asyncCacheExecute:(void(^)(void))block {
    dispatch_async(self.cacheSchemaQueue, block);
}

- (void)setupSchemaConfiguration:(void(^)(void))completion {
    dispatch_barrier_async(self.cacheSchemaQueue, ^{
        @autoreleasepool {
            [self _setOnlyAccessibleWhenUnlocked:self.onlyAccessibleWhenUnlocked];
            
            RLMRealmConfiguration *config = self.defaultConfig;
            config.objectClasses = self.modelClasses;
            
            uint64_t version = self.schemaVersion;
            config.schemaVersion = version;
            __weak __typeof(self)weakSelf = self;
            config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf.migrationBlock) {
                    strongSelf.migrationBlock(migration, oldSchemaVersion, version);
                }
            };
            
            config.shouldCompactOnLaunch = ^BOOL(NSUInteger totalBytes, NSUInteger bytesUsed) {
                NSUInteger compatingSize = 100 * 1024 * 1024;
                double usedPercent = (double)bytesUsed / totalBytes;
                BOOL shouldCompactOnLaunch = (totalBytes > compatingSize) && usedPercent < 0.5;
                #ifdef DEBUG
                if (shouldCompactOnLaunch) {
                    ARLogWarn(@"Schema: `%@` - Total: %f MB, Used: %f %%", self.schemaName, (double)totalBytes / (1024 * 1024), usedPercent * 100);
                } else {
                    ARLogInfo(@"Schema: `%@` - Total: %f MB, Used: %f %%", self.schemaName, (double)totalBytes / (1024 * 1024), usedPercent * 100);
                }
                #endif
                return shouldCompactOnLaunch;
            };
            
            // Encryption Switch
            if (self.dataEncryption) {
                NSData *key = [self searchEncryptionKey];
                if (key) {
                    config.encryptionKey = key;
                    [self defaultRealm];
                } else {
                    key = [self addEncryptionKey];
                    NSURL *tempUrl = ar_realmTempFileURL(self.defaultConfig.fileURL);
                    @autoreleasepool {
                        BOOL result = [[self defaultRealm] writeCopyToURL:tempUrl encryptionKey:key error:nil];
                        if (result) {
                            if ([[NSFileManager defaultManager] removeItemAtURL:config.fileURL error:nil]) {
                                if ([[NSFileManager defaultManager] copyItemAtURL:tempUrl toURL:config.fileURL error:nil]) {
                                    [[NSFileManager defaultManager] removeItemAtURL:tempUrl error:nil];
                                }
                            }
                        }
                    }
                    config.encryptionKey = key;
                    [self defaultRealm];
                }
            } else {
                NSData *key = [self searchEncryptionKey];
                if (key) {
                    [self deleteEncryptionKey];
                    NSURL *tempUrl = ar_realmTempFileURL(self.defaultConfig.fileURL);
                    config.encryptionKey = key;
                    @autoreleasepool {
                        BOOL result = [[self defaultRealm] writeCopyToURL:tempUrl encryptionKey:nil error:nil];
                        if (result) {
                            if ([[NSFileManager defaultManager] removeItemAtURL:config.fileURL error:nil]) {
                                if ([[NSFileManager defaultManager] copyItemAtURL:tempUrl toURL:config.fileURL error:nil]) {
                                    [[NSFileManager defaultManager] removeItemAtURL:tempUrl error:nil];
                                }
                            }
                        }
                    }
                    config.encryptionKey = nil;
                    [self defaultRealm];
                } else {
                    [self defaultRealm];
                }
            }
            
            ARLogInfo(@"Realm: %@", [self defaultRealm].configuration.fileURL);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
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
    ARAssert(status == errSecSuccess, @"Failed to generate random bytes for key");
    NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
    NSData *tag = [ar_dataCacheID(self.schemaName) dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecValueData: keyData,
                            (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked};
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    ARAssert(status == errSecSuccess, @"Failed to insert new key in the keychain");
    return keyData;
}

- (void)deleteEncryptionKey {
    NSData *tag = [ar_dataCacheID(self.schemaName) dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag};
#ifdef DEBUG
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    ARAssert(status == errSecSuccess, @"Failed to delete the invalid key in the keychain");
#else
    SecItemDelete((__bridge CFDictionaryRef)query);
#endif
}

static inline NSString *ar_dataCacheID(NSString *key) {
    return [NSString stringWithFormat:@"%@.arnetwork.%@", [[NSBundle mainBundle] bundleIdentifier], key];
}

static inline NSURL * ar_realmTempFileURL(NSURL *fileURL) {
    return [fileURL.URLByDeletingPathExtension URLByAppendingPathExtension:@".temp.realm"];
}

@end

@implementation ARDataCacheManager (Unavailable)

@end
