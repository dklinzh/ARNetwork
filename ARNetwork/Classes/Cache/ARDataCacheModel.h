//
//  ARDataCacheModel.h
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

@interface ARDataCacheModel : RLMObject
@property NSString *arPrimaryKey;
@property NSDate *arExpiredTime;

+ (instancetype)ar_createInDefaultRealmWithValue:(id)value;

+ (instancetype)ar_createOrUpdateInDefaultRealmWithValue:(id)value;

+ (RLMResults *)ar_allObjects;

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat, ...;

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat args:(va_list)args;

+ (RLMResults *)ar_objectsWithPredicate:(NSPredicate *)predicate;

+ (instancetype)ar_objectForPrimaryKey:(id)primaryKey;

+ (instancetype)dataCache;

+ (instancetype)dataCache:(NSUInteger)index;

+ (NSUInteger)dataCacheCount;

+ (NSArray *)valueUpdatedProperties;

- (instancetype)initDataCacheWithData:(NSDictionary *)data;

- (void)updateDataCacheWithData:(NSDictionary *)data;

- (void)setValueForExtraProperties NS_REQUIRES_SUPER;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<ARDataCacheModel>
RLM_ARRAY_TYPE(ARDataCacheModel)
