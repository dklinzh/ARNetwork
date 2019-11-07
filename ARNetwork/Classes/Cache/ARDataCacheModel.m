//
//  ARDataCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"
#import "_NSObject+ARInspect.h"
#import "_ARDataCacheManager_Private.h"
#import "_ARDataCacheModel_Private.h"
#import "RLMRealm+ARWrite.h"

static inline bool numberIsInteger(__unsafe_unretained NSNumber *const obj) {
    char data_type = [obj objCType][0];
    return data_type == *@encode(bool) ||
    data_type == *@encode(char) ||
    data_type == *@encode(short) ||
    data_type == *@encode(int) ||
    data_type == *@encode(long) ||
    data_type == *@encode(long long) ||
    data_type == *@encode(unsigned short) ||
    data_type == *@encode(unsigned int) ||
    data_type == *@encode(unsigned long) ||
    data_type == *@encode(unsigned long long);
}

static inline bool numberIsBool(__unsafe_unretained NSNumber *const obj) {
    // @encode(BOOL) is 'B' on iOS 64 and 'c'
    // objcType is always 'c'. Therefore compare to "c".
    if ([obj objCType][0] == 'c') {
        return true;
    }
    
    if (numberIsInteger(obj)) {
        int value = [obj intValue];
        return value == 0 || value == 1;
    }
    
    return false;
}

static inline bool numberIsFloat(__unsafe_unretained NSNumber *const obj) {
    char data_type = [obj objCType][0];
    return data_type == *@encode(float) ||
    data_type == *@encode(short) ||
    data_type == *@encode(int) ||
    data_type == *@encode(long) ||
    data_type == *@encode(long long) ||
    data_type == *@encode(unsigned short) ||
    data_type == *@encode(unsigned int) ||
    data_type == *@encode(unsigned long) ||
    data_type == *@encode(unsigned long long) ||
    // A double is like float if it fits within float bounds or is NaN.
    (data_type == *@encode(double) && (ABS([obj doubleValue]) <= FLT_MAX || isnan([obj doubleValue])));
}

static inline bool numberIsDouble(__unsafe_unretained NSNumber *const obj) {
    char data_type = [obj objCType][0];
    return data_type == *@encode(double) ||
    data_type == *@encode(float) ||
    data_type == *@encode(short) ||
    data_type == *@encode(int) ||
    data_type == *@encode(long) ||
    data_type == *@encode(long long) ||
    data_type == *@encode(unsigned short) ||
    data_type == *@encode(unsigned int) ||
    data_type == *@encode(unsigned long) ||
    data_type == *@encode(unsigned long long);
}

static inline void addValidPrimitiveValues(NSArray *values, RLMArray *array, RLMPropertyType type) {
    switch (type) {
        case RLMPropertyTypeBool:
            for (id value in values) {
                if ([value isKindOfClass:NSNumber.class] && numberIsBool(value)) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        case RLMPropertyTypeInt:
            for (id value in values) {
                if ([value isKindOfClass:NSNumber.class] && numberIsInteger(value)) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        case RLMPropertyTypeFloat:
            for (id value in values) {
                if ([value isKindOfClass:NSNumber.class] && numberIsFloat(value)) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        case RLMPropertyTypeDouble:
            for (id value in values) {
                if ([value isKindOfClass:NSNumber.class] && numberIsDouble(value)) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        case RLMPropertyTypeString:
            for (id value in values) {
                if ([value isKindOfClass:NSString.class]) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        case RLMPropertyTypeDate:
            for (id value in values) {
                if ([value isKindOfClass:NSDate.class]) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        case RLMPropertyTypeData:
            for (id value in values) {
                if ([value isKindOfClass:NSData.class]) {
                    [array addObject:value];
                } else {
                    NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not matched with value: %@", @(type), value);
                }
            }
            break;
        default:
            NSCAssert(NO, @"RLMPropertyType<%@> of the RLMArray is not primitive", @(type));
            break;
    }
}

@implementation ARDataCacheModel

+ (RLMRealm *)ar_defaultRealm {
    return [ARDataCacheManager _realmWithModelClass:self.class];
}

+ (BOOL)ar_transactionWithBlock:(__attribute__((noescape)) void(^)(RLMRealm *realm))block error:(NSError **)error {
    RLMRealm *realm = [self ar_defaultRealm];
    return [realm transactionWithBlock:^{
        if (block) {
            block(realm);
        }
    } error:error];
}

+ (instancetype)ar_createInDefaultRealmWithValue:(id)value {
    return [self createInRealm:[self ar_defaultRealm] withValue:value];
}

+ (instancetype)ar_createOrUpdateInDefaultRealmWithValue:(id)value {
    return [self createOrUpdateInRealm:[self ar_defaultRealm] withValue:value];
}

+ (RLMResults *)ar_allObjects {
    return [self allObjectsInRealm:[self ar_defaultRealm]];
}

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat, ... {
    va_list args;
    va_start(args, predicateFormat);
    RLMResults *results = [self ar_objectsWhere:predicateFormat args:args];
    va_end(args);
    return results;
}

+ (RLMResults *)ar_objectsWhere:(NSString *)predicateFormat args:(va_list)args {
    return [self objectsInRealm:[self ar_defaultRealm] where:predicateFormat args:args];
}

+ (RLMResults *)ar_objectsWithPredicate:(NSPredicate *)predicate {
    return [self objectsInRealm:[self ar_defaultRealm] withPredicate:predicate];
}

+ (instancetype)ar_objectForPrimaryKey:(id)primaryKey {
    return [self objectInRealm:[self ar_defaultRealm] forPrimaryKey:primaryKey];
}

#pragma mark -

static inline RLMResults * ar_sortedResults(RLMResults * results) {
    if (results.count > 1) {
        results = [results sortedResultsUsingKeyPath:@"_AR_DATE_MODIFIED" ascending:NO];
        ARLogWarn(@"Data caches of <%@> are more than one.", results.objectClassName);
    }
    return results;
}

+ (instancetype)oldestDataCache {
    RLMResults *results = ar_sortedResults([self ar_allObjects]);
    return results.lastObject;
}

+ (instancetype)latestDataCache {
    RLMResults *results = ar_sortedResults([self ar_allObjects]);
    return results.firstObject;
}

+ (instancetype)dataCache {
    return [self latestDataCache];
}

+ (instancetype)dataCache:(NSUInteger)index {
    RLMResults *results = [self ar_allObjects];
    if (index >= results.count) {
        return nil;
    }
    
    results = ar_sortedResults(results);
    return results[index];
}

+ (NSUInteger)dataCacheCount {
    return [self ar_allObjects].count;
}

+ (instancetype)_dataCacheForKey:(NSString *)cacheKey {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"_AR_CACHE_KEY = %@", cacheKey];
    RLMResults *results = [self ar_objectsWithPredicate:pred];
    results = ar_sortedResults(results);
    return results.firstObject;
}

- (instancetype)initDataCache:(NSDictionary *)data {
    id primaryExist;
    id primaryValue;
    Class selfClass = [self class];
    NSString *primaryKey = [selfClass primaryKey];
    if (primaryKey) {
        primaryValue = [self propertyForKey:primaryKey fromDatas:data];
        if (primaryValue) {
            primaryExist = [selfClass ar_objectForPrimaryKey:primaryValue];
        } else {
            ARAssert(NO, @"The value of primary key `%@` of Class<%@> was nil.", primaryKey, selfClass);
        }
    }
    
    if (primaryExist) {
        self = primaryExist;
        [self updateDataCache:data];
    } else {
        if (primaryKey && primaryValue) {
            NSString *className = [selfClass className];
            NSMutableDictionary<id, ARDataCacheModel *> *tempModels = [ar_primaryExistsTemp() valueForKey:className];
            if (!tempModels) {
                tempModels = [NSMutableDictionary dictionary];
                [ar_primaryExistsTemp() setValue:tempModels forKey:className];
            }
            id tempModel = [tempModels objectForKey:primaryValue];
            if (tempModel) {
                self = tempModel;
            } else {
                self = [super init];
                [tempModels setObject:self forKey:primaryValue];
            }
        } else {
            self = [super init];
        }
        
        NSArray<NSString *> *propertyNames = [self propertyNames];
        for (NSString *key in propertyNames) {
            id value = [data valueForKey:key];
            if (value && ![value isKindOfClass:NSNull.class]) {
                if ([value isKindOfClass:NSDictionary.class]) {
                    Class clazz = [self ar_classOfPropertyNamed:key];
                    if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                        [self setValue:[[clazz alloc] initDataCache:value] forKey:key];
                    }
                } else if ([value isKindOfClass:NSArray.class]) {
                    id obj = [self valueForKey:key];
                    if ([obj isKindOfClass:RLMArray.class]) {
                        RLMArray *objs = (RLMArray *)obj;
                        [objs removeAllObjects];
                        NSArray *values = (NSArray *)value;
                        RLMPropertyType type = objs.type;
                        if (type == RLMPropertyTypeObject) {
                            Class clazz = NSClassFromString(objs.objectClassName);
                            NSMutableSet *primarySet = [NSMutableSet set];
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    NSString *primaryKey = [clazz primaryKey];
                                    if (primaryKey) {
                                        id primaryValue = [[clazz alloc] propertyForKey:primaryKey fromDatas:item];
                                        if (primaryValue) {
                                            if ([primarySet containsObject:primaryValue]) {
                                                continue;
                                            }
                                            
                                            [primarySet addObject:primaryValue];
                                            [objs addObject:[[clazz alloc] initDataCache:item]];
                                        } else {
                                            ARAssert(NO, @"The value of primary key `%@` of Class<%@> was nil.", primaryKey, clazz);
                                        }
                                    } else {
                                        [objs addObject:[[clazz alloc] initDataCache:item]];
                                    }
                                }
                            }
                        } else {
                            addValidPrimitiveValues(values, objs, type);
                        }
                    }
                } else {
                    [self setPropertyValue:value forKey:key];
                }
            } else {
                [self resetDefaultValueForKey:key];
            }
        }
        
        if ([self respondsToSelector:@selector(ar_transactionForPropertyValues:)]) {
            [self ar_transactionForPropertyValues:data];
        }
    }
    return self;
}

- (void)resetDefaultValueForKey:(NSString *)key {
    Class selfClass = [self class];
    NSDictionary *defaultPropertyValues = [selfClass defaultPropertyValues];
    id defaultValue = [defaultPropertyValues valueForKey:key];
    if (defaultValue) {
        ARLogWarn(@"Reset default value to the property '%@' of class '%@'", key, selfClass);
        [self setValue:defaultValue forKey:key];
    } else {
        id value = [self valueForKey:key];
        if (value) {
            if ([value isKindOfClass:NSValue.class]) {
                if (![value isEqual:@(0)]) {
                    ARLogWarn(@"Reset default value to the property '%@' of class '%@'", key, selfClass);
                    [self setValue:@(0) forKey:key];
                }
            } else if ([value conformsToProtocol:@protocol(RLMCollection)]) {
                if ([value count] > 0) {
                    ARLogWarn(@"Reset default value to the property '%@' of class '%@'", key, selfClass);
                    [value removeAllObjects];
                }
            } else {
                ARLogWarn(@"Reset default value to the property '%@' of class '%@'", key, selfClass);
                [self setValue:nil forKey:key];
            }
        }
    }
}

//- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//
//}

- (NSArray<NSString *> *)propertyNames {
    NSMutableArray<NSString *> *propertyNames = [NSMutableArray array];
    Class superclass = self.superclass;
    while (![superclass isEqual:ARDataCacheModel.class]) {
        [propertyNames addObjectsFromArray:[superclass ar_propertyNamesForClassOnly]];
        NSArray<NSString *> *ignoredProperties = [superclass ignoredProperties];
        if (ignoredProperties) {
            [propertyNames removeObjectsInArray:ignoredProperties];
        }
        ignoredProperties = [superclass ar_reservedProperties];
        if (ignoredProperties) {
            [propertyNames removeObjectsInArray:ignoredProperties];
        }
        
        superclass = [superclass superclass];
    }
    return [propertyNames copy];
}

- (id)propertyForKey:(NSString *)key fromDatas:(NSDictionary *)datas {
    id value = [datas valueForKey:key];
    if (!value || [value isKindOfClass:NSNull.class]) {
        return nil;
    }
    
    Class class = [self ar_classOfPropertyNamed:key];
    if ([class isSubclassOfClass:NSString.class] && ![value isKindOfClass:NSString.class]) {
        value = [NSString stringWithFormat:@"%@", value];
    }
    return value;
}

- (void)setPropertyValue:(id)value forKey:(NSString *)key {
    Class class = [self ar_classOfPropertyNamed:key];
    if ([class isSubclassOfClass:NSString.class]) {
        if (![value isKindOfClass:NSString.class]) {
            value = [NSString stringWithFormat:@"%@", value];
        }
    } else if ([class conformsToProtocol:@protocol(RLMThreadConfined)]) {
        ARAssert(NO, @"The type of key-value does not match! Key<%@> != Value<%@>", class, [value class]);
        return;
    }
    
    [self setValue:value forKey:key];
}

- (void)_clearPrimaryExistsTemp {
    [ar_primaryExistsTemp() removeAllObjects];
}

static NSMutableDictionary<NSString *, NSMutableDictionary *> * ar_primaryExistsTemp() {
    static NSMutableDictionary<NSString *, NSMutableDictionary *> *ar_primaryExistsTemp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ar_primaryExistsTemp = [[NSMutableDictionary alloc] init];
    });
    return ar_primaryExistsTemp;
}

- (void)_addOrUpdateDataCache:(NSDictionary *)data forKey:(NSString *)cacheKey {
    if (!self.realm) {
        self._AR_CACHE_KEY = cacheKey;
        Class selfClass = [self class];
        if (![selfClass ar_shouldForceUpdateWithoutCompare]) {
            self._AR_CACHE_CODE = ar_cacheCode(data);
        }
        NSDate *date = [NSDate date];
        self._AR_DATE_MODIFIED = date;
        self._AR_DATE_EXPIRED = [NSDate dateWithTimeInterval:[selfClass ar_expiredInterval] sinceDate:date];
        [self _addOrUpdateDataCache];
    }
    
    [self _clearPrimaryExistsTemp];
}

- (void)_addOrUpdateDataCache {
    Class selfClass = [self class];
    RLMRealm *realm = [selfClass ar_defaultRealm];
    BOOL inWriteTransaction = !realm.inWriteTransaction;
    if (inWriteTransaction) {
        [realm beginWriteTransaction];
    }
    if ([self respondsToSelector:@selector(ar_transactionDidBeginWrite)]) {
        [self ar_transactionDidBeginWrite];
    }
    
    if ([selfClass primaryKey]) {
        [realm addOrUpdateObject:self];
    } else {
        [realm addObject:self];
    }
    
    if ([self respondsToSelector:@selector(ar_transactionWillCommitWrite)]) {
        [self ar_transactionWillCommitWrite];
    }
    if (inWriteTransaction) {
        [realm commitWriteTransaction];
    }
}

+ (instancetype)addOrUpdateDataCache:(NSDictionary *)data {
    __kindof ARDataCacheModel *model = [[self alloc] initDataCache:data];
    if (!model.realm) {
        [model _addOrUpdateDataCache];
    }
    return model;
}

- (void)updateDataCache:(NSDictionary *)data {
    if (!self.isInvalidated) {
        Class selfClass = [self class];
        RLMRealm *realm = [selfClass ar_defaultRealm];
        BOOL inWriteTransaction = !realm.inWriteTransaction;
        if (inWriteTransaction) {
            [realm beginWriteTransaction];
        }
        if ([self respondsToSelector:@selector(ar_transactionDidBeginWrite)]) {
            [self ar_transactionDidBeginWrite];
        }
        NSDate *date = [NSDate date];
        if ([selfClass ar_shouldForceUpdateWithoutCompare]) {
            if (self._AR_CACHE_CODE) {
                self._AR_CACHE_CODE = nil;
            }
            if (self._AR_DATE_MODIFIED) {
                self._AR_DATE_MODIFIED = date;
            }
            [self updateDataCacheWithDataPartInTransaction:data];
        } else {
            NSString *cacheCode = ar_cacheCode(data);
            if (![cacheCode isEqualToString:self._AR_CACHE_CODE]) {
                self._AR_CACHE_CODE = cacheCode;
                if (self._AR_DATE_MODIFIED) {
                    self._AR_DATE_MODIFIED = date;
                }
                [self updateDataCacheWithDataPartInTransaction:data];
            }
        }
        if (self._AR_DATE_EXPIRED) {
            self._AR_DATE_EXPIRED = [NSDate dateWithTimeInterval:[selfClass ar_expiredInterval] sinceDate:date];
        }
        
        if ([self respondsToSelector:@selector(ar_transactionWillCommitWrite)]) {
            [self ar_transactionWillCommitWrite];
        }
        if (inWriteTransaction) {
            [realm commitWriteTransaction];
        }
    }
    
    [self _clearPrimaryExistsTemp];
}

- (void)updateDataCacheWithDataPartInTransaction:(NSDictionary *)data {
    Class selfClass = [self class];
    NSArray *equalValueSkippedProperties = [selfClass ar_equalValueSkippedProperties];
    NSString *primaryKey = [selfClass primaryKey];
    
    NSArray<NSString *> *propertyNames = [self propertyNames];
    for (NSString *key in propertyNames) {
        if ([primaryKey isEqualToString:key]) {
            continue;
        }
        
        if ([equalValueSkippedProperties containsObject:key]) {
            id value = [self valueForKey:key];
            if ([value isEqual:data[key]]) {
                continue;
            }
        }
        
        id value = [data valueForKey:key];
        if (value && ![value isKindOfClass:NSNull.class]) {
            if ([value isKindOfClass:NSDictionary.class]) {
                Class clazz = [self ar_classOfPropertyNamed:key];
                if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                    id obj = [self valueForKey:key];
                    if (obj) {
                        [obj updateDataCacheWithDataPartInTransaction:value];
                    } else {
                        [self setValue:[[clazz alloc] initDataCache:value] forKey:key];
                    }
                }
            } else if ([value isKindOfClass:NSArray.class]) {
                id obj = [self valueForKey:key];
                if ([obj isKindOfClass:RLMArray.class]) {
                    RLMArray *objs = (RLMArray *)obj;
                    NSArray *values = (NSArray *)value;
                    RLMPropertyType type = objs.type;
                    if (type == RLMPropertyTypeObject) {
                        Class clazz = NSClassFromString(objs.objectClassName);
                        NSString *primaryKey = [clazz primaryKey];
                        if (primaryKey) {
                            NSMutableSet *primarySet = [NSMutableSet set];
                            NSMutableArray *uniqueValues = [NSMutableArray array];
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    id key = [[clazz alloc] propertyForKey:primaryKey fromDatas:item];
                                    if (key) {
                                        if ([primarySet containsObject:key]) {
                                            continue;
                                        }
                                        
                                        [primarySet addObject:key];
                                        [uniqueValues addObject:item];
                                    } else {
                                        ARAssert(NO, @"The value of primary key `%@` of Class<%@> was nil.", primaryKey, clazz);
                                    }
                                }
                            }
                            
                            NSMutableArray *deletedObjs = [NSMutableArray array];
                            for (id item in objs) {
                                if ([primarySet containsObject:[item valueForKey:primaryKey]]) {
                                    continue;
                                }
                                
                                [deletedObjs addObject:item];
                            }
                            [[selfClass ar_defaultRealm] ar_cascadeDeleteObjcets:deletedObjs
                                                             isPrimaryKeySkipped:[selfClass ar_primaryKeyRetain]];
                            primarySet = nil;
                            
                            [objs removeAllObjects];
                            for (id item in uniqueValues) {
                                id primaryValue = [[clazz alloc] propertyForKey:primaryKey fromDatas:item];
                                if (primaryValue) {
                                    id primaryExist = [clazz ar_objectForPrimaryKey:primaryValue];
                                    if (primaryExist) {
                                        [primaryExist updateDataCacheWithDataPartInTransaction:item];
                                        [objs addObject:primaryExist];
                                    } else {
                                        [objs addObject:[[clazz alloc] initDataCache:item]];
                                    }
                                } else {
                                    ARAssert(NO, @"The value of primary key `%@` of Class<%@> was nil.", primaryKey, clazz);
                                }
                            }
                        } else {
                            [[selfClass ar_defaultRealm] ar_cascadeDeleteObjcets:objs
                                                             isPrimaryKeySkipped:[selfClass ar_primaryKeyRetain]];
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    [objs addObject:[[clazz alloc] initDataCache:item]];
                                }
                            }
                        }
                    } else {
                        [objs removeAllObjects];
                        addValidPrimitiveValues(values, objs, type);
                    }
                }
            } else {
                [self setPropertyValue:value forKey:key];
            }
        } else {
            [self resetDefaultValueForKey:key];
        }
    }
    
    if ([self respondsToSelector:@selector(ar_transactionForPropertyValues:)]) {
        [self ar_transactionForPropertyValues:data];
    }
}

@end

@implementation ARDataCacheModel (Property)

+ (NSTimeInterval)ar_expiredInterval {
    return [ARDataCacheManager _managerWithModelClass:self.class].expiredInterval;
}

+ (NSArray<NSString *> *)ar_equalValueSkippedProperties {
    return nil;
}

+ (NSArray<NSString *> *)ar_reservedProperties {
    return nil;
}

+ (BOOL)ar_shouldForceUpdateWithoutCompare {
    return YES;
}

+ (BOOL)ar_primaryKeyRetain {
    return YES;
}

@end

@implementation ARDataCacheModel (ThreadSafe)

+ (instancetype)ar_resolveThreadSafeReference:(RLMThreadSafeReference *)reference {
    return [[self ar_defaultRealm] resolveThreadSafeReference:reference];
}

- (instancetype)ar_resolveMainThreadSafeReference {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    __block RLMThreadSafeReference *reference = nil;
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        reference = [RLMThreadSafeReference referenceWithThreadConfined:self];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    id data = [self.class ar_resolveThreadSafeReference:reference];
    reference = nil;
    dispatch_semaphore_signal(semaphore);
    return data;
}

@end

