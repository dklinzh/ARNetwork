//
//  ARDataCacheModel.h
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ARDataCacheModelTransaction <NSObject>

@optional
- (void)setValueForExtraProperties;

@end

/**
 The base class of object modeling from reponse data with cache.
 */
@interface ARDataCacheModel : RLMObject <ARDataCacheModelTransaction>

+ (RLMRealm *)ar_defaultRealm;

/**
 Creates an instance of the `ARDataCacheModel` object with a given value, and adds it to the default Realm database.

 @param value The value used to populate the object.
 @return An instance of the `ARDataCacheModel` object.
 */
+ (instancetype)ar_createInDefaultRealmWithValue:(id)value;

/**
 Creates or updates an `ARDataCacheModel` object within the default Realm database.

 @param value The value used to populate the object.
 @return An instance of the `ARDataCacheModel` object.
 */
+ (instancetype)ar_createOrUpdateInDefaultRealmWithValue:(id)value;

/**
 Returns all objects of this object type from the default Realm database.

 @return An `RLMResults` containing all objects of this type in the default Realm database.
 */
+ (RLMResults *)ar_allObjects;

/**
 Returns all objects of this object type matching the given predicate from the default Realm database.

 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.
 @return An `RLMResults` containing all objects of this type in the default Realm database that match the given predicate.
 */
+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat, ...;

/**
 Returns all objects of this object type matching the given predicate from the default Realm database.

 @param predicateFormat A predicate format string.
 @param args A variable number of arguments.
 @return An `RLMResults` containing all objects of this type in the default Realm database that match the given predicate.
 */
+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Returns all objects of this object type matching the given predicate from the default Realm database.

 @param predicate A predicate to use to filter the elements.
 @return An `RLMResults` containing all objects of this type in the default Realm database that match the given predicate.
 */
+ (RLMResults *)ar_objectsWithPredicate:(NSPredicate *)predicate;


/**
 Returns the single instance of this object type with the given primary key from the default Realm database.

 @param primaryKey The value of primary key.
 @return An object of this object type, or `nil` if an object with the given primary key does not exist.
 */
+ (nullable instancetype)ar_objectForPrimaryKey:(id)primaryKey;

/**
 Returns the latest cache data of this object type from the default Realm database.

 @return An instance of this kind of object
 */
+ (nullable instancetype)dataCache;

/**
 Returns the cache data of this object type with the given index from the default Realm database.

 @param index An index of the object in the `RLMResults` contains all objects of this type.
 @return An instance of this kind of object.
 */
+ (nullable instancetype)dataCache:(NSUInteger)index;

/**
 Returns the number of all objects of this type from the default Realm database.

 @return The number of all objects of this type.
 */
+ (NSUInteger)dataCacheCount;

/**
 Override this method to specify the name of properties that its value will not be updated if the value is equal to the original one.

 @return An array of property names.
 */
+ (nullable NSArray *)equalValueSkippedProperties;

/**
 Override this method to specify the time interval of expired cache data to this kind of object. Defaults to 0 s.

 @return A time interval, in seconds.
 */
+ (NSTimeInterval)expiredInterval;

/**
 Create an instance of this kind of object with the given dictionary.

 @param data A given dictionary to modeling.
 @return An instance of this kind of object.
 */
- (instancetype)initDataCache:(NSDictionary *)data;

/**
 Update the cache data of this object type in the default Realm database.

 @param data A given dictionary to update the cache data in the default Realm database.
 */
- (void)updateDataCache:(NSDictionary *)data;

@end
RLM_ARRAY_TYPE(ARDataCacheModel)

@interface ARDataCacheModel (ThreadSafe)

- (instancetype)ar_resolveThreadSafeReference:(RLMThreadSafeReference *)reference;

- (instancetype)ar_resolveMainThreadSafeReference;

@end

/**
 Wraped string object for storing flat arrays of strings on a Realm model
 */
@interface ARWrapedString : ARDataCacheModel
@property NSString *value;

/**
 Creates an unmanaged instance of a wraped string Realm object.

 @param string The value of string
 @return ARCacheString instance
 */
- (instancetype)initWithString:(NSString *)string;

@end
RLM_ARRAY_TYPE(ARWrapedString)

NS_ASSUME_NONNULL_END
