//
//  ARDataCache.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

typedef NS_ENUM(NSInteger, ARCacheType) {
    ARCacheTypeNone = 0,
    ARCacheTypeOnlyLoad = 1,
    ARCacheTypeOnlyUpdate = 1 << 1,
    ARCacheTypeUpdateIfNeeded = 1 << 2,
    ARCacheTypeLoadAndUpdate = ARCacheTypeOnlyLoad | ARCacheTypeOnlyUpdate,
    ARCacheTypeLoadAndUpdateIfNeeded = ARCacheTypeOnlyLoad | ARCacheTypeUpdateIfNeeded,
};

typedef NS_ENUM(NSInteger, ARCacheError) {
    ARCacheErrorNone = -1000, // Have no cache in local.
    ARCacheErrorSource = -1001, // Type of data source is wrong.
    ARCacheErrorModel = -1002, // Format of class model is wrong.
};
