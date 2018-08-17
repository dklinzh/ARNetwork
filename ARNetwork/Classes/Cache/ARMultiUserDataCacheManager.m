//
//  ARMultiUserDataCacheManager.m
//  ARNetwork
//
//  Created by Daniel Lin on 2018/8/14.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

#import "ARMultiUserDataCacheManager.h"
#import <Realm/Realm.h>
#import "_NSString+ARSHA1.h"

@interface ARDataCacheManager ()
@property (nonatomic, strong) RLMRealmConfiguration *defaultConfig;
@property (nonatomic, copy) NSString *schemaName;
@property (nonatomic, assign) NSUInteger schemaVersion;
@property (nonatomic, assign) BOOL dataEncryption;
@property (nonatomic, strong) NSURL *defaultFileURL;
@property (nonatomic, strong) dispatch_queue_t cacheSchemaQueue;
@property (nonatomic, copy) NSArray<Class> *modelClasses;

- (void)_setOnlyAccessibleWhenUnlocked:(BOOL)onlyAccessibleWhenUnlocked;
- (void)_setReadOnly:(BOOL)readOnly;
- (void)_setMemoryOnly:(BOOL)memoryOnly;
- (void)_registerModels:(NSArray<Class> *)classes;
- (void)setupSchemaConfiguration:(void(^)(void))completion;
@end

@interface ARMultiUserDataCacheManager()
@property (nonatomic, copy) NSString *_schemaName;
@property (nonatomic, copy) NSString *userAccount;
@end

@implementation ARMultiUserDataCacheManager

- (instancetype)initWithSchema:(NSString *)schemaName version:(NSUInteger)version encryption:(BOOL)enabled {
    if (self = [super initWithSchema:schemaName version:version encryption:enabled]) {
        __schemaName = schemaName;
    }
    return self;
}

- (NSString *)schemaName {
    return [NSString stringWithFormat:@"%@.%@", self._schemaName, self.userAccount];
}

- (void)registerModels:(NSArray<Class> *)classes {
    self.modelClasses = classes;
    
    [self _registerModels:classes];
}

- (void)switchUserDataWithAccount:(NSString *)account completion:(void(^)(void))completion {
    NSString *userAccount = account.ar_SHA1;
    if ([self.userAccount isEqualToString:userAccount]) {
        if (completion) {
            completion();
        }
        return;
    }
    
    self.userAccount = userAccount;
    
    self.defaultFileURL = nil;
    self.defaultConfig = nil;
    self.cacheSchemaQueue = nil;
    [self _setOnlyAccessibleWhenUnlocked:self.onlyAccessibleWhenUnlocked];
    if (self.readOnly) {
        [self _setReadOnly:YES];
    }
    if (self.memoryOnly) {
        [self _setMemoryOnly:YES];
    }
        
    [self setupSchemaConfiguration:completion];
}

- (void)clearUserDataCache {
    if (!self.userAccount) {
        ARAssert(NO, @"None of user account has been opened");
        return;
    }
    
    [self clearAllDataCaches];
}

- (void)clearUserDataCacheWithAccount:(NSString *)account {
    __weak __typeof(self)weakSelf = self;
    [self switchUserDataWithAccount:account completion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf clearAllDataCaches];
    }];
}

@end
