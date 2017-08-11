//
//  ARDataCache.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//


/**
 The operation type of reponse data with local cache.
 */
typedef NS_OPTIONS(NSInteger, ARCacheType) {
    ARCacheTypeNone = 0, // Do not use the operation of data cache.
    ARCacheTypeOnlyLoad = 1, // Only load data if there are valid caches in local, otherwise create cache with data source from remote server.
    ARCacheTypeOnlyUpdate = 1 << 1, // Only create or update cache with data source from remote server.
    ARCacheTypeUpdateIfNeeded = 1 << 2, // Only create or update cache with data source from remote server if the local cache was expired.
    ARCacheTypeLoadAndUpdate = ARCacheTypeOnlyLoad | ARCacheTypeOnlyUpdate, // Load the existed data in local and then create or update cache with data source from remote server.
    ARCacheTypeLoadAndUpdateIfNeeded = ARCacheTypeOnlyLoad | ARCacheTypeUpdateIfNeeded, // Load the existed data in local and then create or update cache with data source from remote server if the local cache was expired.
};


/**
 The error type in the request/reponse operation.
 */
typedef NS_ENUM(NSInteger, ARCacheError) {
    ARCacheErrorNone = -1000, // Have no cache in local.
    ARCacheErrorSource = -1001, // The type of data source is wrong.
    ARCacheErrorModel = -1002, // The format of class model is wrong.
};
