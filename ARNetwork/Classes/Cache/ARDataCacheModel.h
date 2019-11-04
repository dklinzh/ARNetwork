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
- (void)ar_transactionForPropertyValues:(NSDictionary *)data;
- (void)ar_transactionDidBeginWrite;
- (void)ar_transactionWillCommitWrite;

@end

/**
 The base class of object modeling from reponse data with cache.
 */
@interface ARDataCacheModel : RLMObject <ARDataCacheModelTransaction>

/**
 Obtains an instance of the default Realm for this Class.

 @return The default `RLMRealm` instance for
 */
+ (RLMRealm *)ar_defaultRealm;

/**
 Performs actions contained within the given block inside a write transaction on the default Realm for this Class.

 @param block The block containing actions to perform.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem. If you are not interested in possible errors, pass in `NULL`.
 @return Whether the transaction succeeded.
 */
+ (BOOL)ar_transactionWithBlock:(__attribute__((noescape)) void(^)(RLMRealm *realm))block error:(NSError **)error;

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
 Returns the oldest cache data of this object type from the default Realm database.
 
 @return An instance of this kind of object
 */
+ (nullable instancetype)oldestDataCache;

/**
 Returns the latest cache data of this object type from the default Realm database.
 
 @return An instance of this kind of object
 */
+ (nullable instancetype)latestDataCache;

/**
 Returns the latest cache data of this object type from the default Realm database.

 @return An instance of this kind of object
 */
+ (nullable instancetype)dataCache DEPRECATED_MSG_ATTRIBUTE("Use +latestDataCache instead.");

/**
 Returns the cache data of this object type with the given query index from the default Realm database.

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
 Create an instance of this kind of object with the given dictionary.

 @param data A given dictionary to modeling.
 @return An instance of this kind of object.
 */
- (instancetype)initDataCache:(NSDictionary *)data;

/**
 Adds or updates an existing object of data cache into the default Realm database.

 @param data A given dictionary to modeling.
 @return An instance of this kind of object.
 */
+ (instancetype)addOrUpdateDataCache:(NSDictionary *)data;

/**
 Update the cache data of this object type in the default Realm database.

 @param data A given dictionary to update the cache data in the default Realm database.
 */
- (void)updateDataCache:(NSDictionary *)data;

@end
RLM_ARRAY_TYPE(ARDataCacheModel)

@interface ARDataCacheModel (Property)

/**
 Override this method to specify the name of properties that its value will not be updated if the value is equal to the original one.
 
 @return An array of property names.
 */
+ (nullable NSArray<NSString *> *)ar_equalValueSkippedProperties;

/**
 Override this method to specify the name of properties that should be reserved outside the data source
 
 @return An array of property names.
 */
+ (nullable NSArray<NSString *> *)ar_reservedProperties;

/**
 Override this method to specify the time interval of expired cache data to this kind of object. Defaults to 0 s.
 
 @return A time interval, in seconds.
 */
+ (NSTimeInterval)ar_expiredInterval;

/**
 Override this method to determine whether or not the data cache should be updated forcely without hash code comparation.

 @return Defaults to true.
 */
+ (BOOL)ar_shouldForceUpdateWithoutCompare;

+ (BOOL)ar_primaryKeyRetain;

@end

@interface ARDataCacheModel (ThreadSafe)

+ (instancetype)ar_resolveThreadSafeReference:(RLMThreadSafeReference *)reference;

- (instancetype)ar_resolveMainThreadSafeReference __attribute__ ((deprecated));;

@end

NS_ASSUME_NONNULL_END
