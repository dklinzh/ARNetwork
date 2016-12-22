//
//  ARDataCache.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

typedef NS_ENUM(NSInteger, ARDataCache) {
    ARDataCacheNone = 0,
    ARDataCacheOnlyLoad = 1,
    ARDataCacheOnlyUpdate = 1 << 1,
    ARDataCacheUpdateIfNeeded = 1 << 2,
    ARDataCacheLoadAndUpdate = ARDataCacheOnlyLoad | ARDataCacheOnlyUpdate,
    ARDataCacheLoadAndUpdateIfNeeded = ARDataCacheOnlyLoad | ARDataCacheUpdateIfNeeded,
};

typedef NS_ENUM(NSInteger, ARCacheError) {
    ARCacheErrorNone = -1000, // Have no cache in local.
    ARCacheErrorSource = -1001, // Type of data source is wrong.
    ARCacheErrorModel = -1002, // Format of class model is wrong.
};
