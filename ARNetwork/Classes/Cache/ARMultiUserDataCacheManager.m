//
//  ARMultiUserDataCacheManager.m
//  ARNetwork
//
//  Created by Daniel Lin on 2018/8/14.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

#import "ARMultiUserDataCacheManager.h"
#import <Realm/Realm.h>

@interface ARDataCacheManager ()
@property (nonatomic, strong) RLMRealmConfiguration *defaultConfig;
@property (nonatomic, copy) NSString *schemaName;
@property (nonatomic, strong) NSURL *defaultFileURL;
@property (nonatomic, strong) dispatch_queue_t cacheSchemaQueue;

- (void)_setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked;
- (void)_setReadOnly:(BOOL)readOnly;
- (void)_setMemoryOnly:(BOOL)memoryOnly;
- (void)setupWithSchemaVersion:(uint64_t)version dataEncryption:(BOOL)enabled;
@end

@interface ARMultiUserDataCacheManager()
@property (nonatomic, assign) NSUInteger schemaVersion;
@property (nonatomic, assign) BOOL dataEncryption;
@property (nonatomic, copy) NSString *_schemaName;
@property (nonatomic, copy) NSString *userAccount;
@end

@implementation ARMultiUserDataCacheManager

- (instancetype)initWithSchema:(NSString *)schemaName version:(NSUInteger)version encryption:(BOOL)enabled {
    if (self = [super init]) {
        self._schemaName = schemaName;
        self.schemaVersion = version;
        self.dataEncryption = enabled;
    }
    return self;
}

- (NSString *)schemaName {
    return [NSString stringWithFormat:@"%@/%@", self._schemaName, self.userAccount];
}

- (void)switchUserDataWithAccount:(NSString *)account {
    self.userAccount = account;
    
    self.defaultFileURL = nil;
    self.defaultConfig = nil;
    self.cacheSchemaQueue = nil;
    [self _setOnlyAccessibleWhenUnlocked:self.onlyAccessibleWhenUnlocked];
    [self _setReadOnly:self.readOnly];
    [self _setMemoryOnly:self.memoryOnly];
        
    [self setupWithSchemaVersion:self.schemaVersion dataEncryption:self.dataEncryption];
}

@end
