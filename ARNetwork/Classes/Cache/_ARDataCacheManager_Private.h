//
//  _ARDataCacheManager_Private.h
//  ARNetwork
//
//  Created by Daniel Lin on 26/09/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.
//

#import "ARDataCacheManager.h"

@interface ARDataCacheManager ()

+ (RLMRealm *)_realmWithModelClass:(Class)clazz;

+ (instancetype)_managerWithModelClass:(Class)clazz;

@end
