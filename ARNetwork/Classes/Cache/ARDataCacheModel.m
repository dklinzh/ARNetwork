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

@implementation ARDataCacheModel

+ (RLMRealm *)ar_defaultRealm {
    return [ARDataCacheManager _realmWithModelClass:self.class];
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
+ (NSTimeInterval)expiredInterval {
    return [ARDataCacheManager _managerWithModelClass:self.class].expiredInterval;
}

+ (NSArray *)equalValueSkippedProperties {
    return nil;
}

+ (instancetype)dataCache {
    return [self dataCache:0];
}

+ (instancetype)dataCache:(NSUInteger)index {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    if (index + 1 > results.count) {
        return nil;
    }
    return results[index];
}

+ (NSUInteger)dataCacheCount {
    RLMResults<__kindof ARDataCacheModel *> *results = [self ar_allObjects];
    return results.count;
}

+ (instancetype)_dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!urlStr) {
        return nil;
    }
    
    NSString *arPrimaryKey = ar_cacheKey(urlStr, params);
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"_AR_CACHE_KEY = %@", arPrimaryKey];
    RLMResults<__kindof ARDataCacheModel *> *caches = [self ar_objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}

- (instancetype)initDataCache:(NSDictionary *)data {
    id primaryExist;
    id primaryValue;
    NSString *primaryKey = [self.class primaryKey];
    if (primaryKey) {
        primaryValue = [self propertyForKey:primaryKey fromDatas:data];
        if (primaryValue) {
            primaryExist = [self.class ar_objectForPrimaryKey:primaryValue];
        }
    }
    
    if (primaryExist) {
        self = primaryExist;
        [self updateDataCache:data];
    } else {
        if (primaryKey) {
            NSString *className = NSStringFromClass(self.class);
            NSMutableDictionary<id, ARDataCacheModel *> *tempModels = [ar_primaryExistsTemp() valueForKey:className];
            if (!tempModels) {
                tempModels = [NSMutableDictionary dictionary];
                [ar_primaryExistsTemp() setValue:tempModels forKey:className];
            }
            id tempModel = [tempModels valueForKey:primaryValue];
            if (tempModel) {
                self = tempModel;
            } else {
                self = [super init];
                [tempModels setValue:self forKey:primaryValue];
            }
        } else {
            self = [super init];
        }
        
        [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                if ([value isKindOfClass:NSDictionary.class]) {
                    Class clazz = [self ar_classOfPropertyNamed:key];
                    if ([clazz isSubclassOfClass:ARDataCacheModel.class]) {
                        [self setValue:[[clazz alloc] initDataCache:value] forKey:key];
                    }
                } else if ([value isKindOfClass:NSArray.class]) {
                    id obj = [self valueForKey:key];
                    if ([obj isKindOfClass:RLMArray.class]) {
                        RLMArray *objs = (RLMArray *)obj;
                        if (objs.type == RLMPropertyTypeObject) {
                            Class clazz = NSClassFromString(objs.objectClassName);
                            NSArray *values = (NSArray *)value;
                            NSMutableOrderedSet *primarySet = [NSMutableOrderedSet orderedSet];
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    NSString *primaryKey = [clazz primaryKey];
                                    if (primaryKey) {
                                        id primaryValue = [[clazz alloc] propertyForKey:primaryKey fromDatas:item];
                                        if (primaryValue) {
                                            NSUInteger primaryIndex = [primarySet indexOfObject:primaryValue];
                                            if (primaryIndex == NSNotFound) {
                                                [primarySet addObject:primaryValue];
                                                [objs addObject:[[clazz alloc] initDataCache:item]];
                                            } else {
                                                [objs replaceObjectAtIndex:primaryIndex withObject:[[clazz alloc] initDataCache:item]];
                                            }
                                        }
                                    } else {
                                        [objs addObject:[[clazz alloc] initDataCache:item]];
                                    }
                                }
                            }
                        } else if (objs.type == RLMPropertyTypeString ||
                                   objs.type == RLMPropertyTypeBool ||
                                   objs.type == RLMPropertyTypeInt ||
                                   objs.type == RLMPropertyTypeFloat ||
                                   objs.type == RLMPropertyTypeDouble ||
                                   objs.type == RLMPropertyTypeDate ||
                                   objs.type == RLMPropertyTypeData) {
                            [objs addObjects:value];
                        }
                    }
                } else {
                    [self setPropertyValue:value forKey:key];
                }
            }
        }];
        
        if ([self respondsToSelector:@selector(setValueForExtraProperties)]) {
            [self setValueForExtraProperties];
        }
    }
    return self;
}

- (id)propertyForKey:(NSString *)key fromDatas:(NSDictionary *)datas {
    id value = [datas valueForKey:key];
    if (!value) {
        return nil;
    }
    
    Class class = [self ar_classOfPropertyNamed:key];
    if ([class isSubclassOfClass:NSString.class]) {
        if (![value isKindOfClass:NSString.class]) {
            value = [NSString stringWithFormat:@"%@", value];
        }
    }
    return value;
}

- (void)setPropertyValue:(id)value forKey:(NSString *)key {
    Class class = [self ar_classOfPropertyNamed:key];
    if ([class isSubclassOfClass:NSString.class]) {
        if (![value isKindOfClass:NSString.class]) {
            value = [NSString stringWithFormat:@"%@", value];
        }
    }
//    else if (!class) {
//        if ([value isKindOfClass:NSString.class]) {
//            NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
//            format.numberStyle = NSNumberFormatterDecimalStyle;
//            value = [format numberFromString:value];
//            if (!value) {
//                return;
//            }
//        }
//    }
    [self setValue:value forKey:key];
}

static NSMutableDictionary<NSString *, NSMutableDictionary *> * ar_primaryExistsTemp() {
    static NSMutableDictionary<NSString *, NSMutableDictionary *> *ar_primaryExistsTemp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ar_primaryExistsTemp = [NSMutableDictionary dictionary];
    });
    return ar_primaryExistsTemp;
}

- (void)_addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!self.realm) {
        self._AR_CACHE_KEY = ar_cacheKey(urlStr, params);
        self._AR_DATE_MODIFIED = [NSDate date];
        self._AR_DATE_EXPIRED = [NSDate dateWithTimeInterval:[self.class expiredInterval] sinceDate:self._AR_DATE_MODIFIED];
        RLMRealm *realm = [self.class ar_defaultRealm];
        BOOL inWriteTransaction = !realm.inWriteTransaction;
        if (inWriteTransaction) {
            [realm beginWriteTransaction];
        }
            
        if ([self.class primaryKey]) {
            [realm addOrUpdateObject:self];
        } else {
            [realm addObject:self]; // FIXME: properties with primary key
        }
        
        if (inWriteTransaction) {
            [realm commitWriteTransaction];
        }
    }
    
    [ar_primaryExistsTemp() removeAllObjects];
}

- (void)updateDataCache:(NSDictionary *)data {
    if (!self.isInvalidated) {
        RLMRealm *realm = [self.class ar_defaultRealm];
        BOOL inWriteTransaction = !realm.inWriteTransaction;
        if (inWriteTransaction) {
            [realm beginWriteTransaction];
        }
        
        [self updateDataCacheWithDataPartInTransaction:data];
        self._AR_DATE_MODIFIED = [NSDate date];
        self._AR_DATE_EXPIRED = self._AR_DATE_EXPIRED = [NSDate dateWithTimeInterval:[self.class expiredInterval] sinceDate:self._AR_DATE_MODIFIED];
        
        if (inWriteTransaction) {
            [realm commitWriteTransaction];
        }
    }
    
    [ar_primaryExistsTemp() removeAllObjects];
}

- (void)updateDataCacheWithDataPartInTransaction:(NSDictionary *)data {
    NSArray *equalValueSkippedProperties = [self.class equalValueSkippedProperties];
    NSString *primaryKey = [self.class primaryKey];
    [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if ([primaryKey isEqualToString:key]) {
            return;
        }
        
        if ([self respondsToSelector:NSSelectorFromString(key)]) {
            if ([equalValueSkippedProperties containsObject:key]) {
                id value = [self valueForKey:key];
                if ([value isEqual:data[key]]) {
                    return;
                }
            }
            
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
                    if (objs.type == RLMPropertyTypeObject) {
                        NSArray *values = (NSArray *)value;
                        Class clazz = NSClassFromString(objs.objectClassName);
                        NSString *primaryKey = [clazz primaryKey];
                        if (primaryKey) {
                            NSMutableOrderedSet *tempKeys = [NSMutableOrderedSet orderedSet];
                            NSMutableDictionary *tempValues = [NSMutableDictionary dictionary];
                            for (id item in values) {
                                id key = [[clazz alloc] propertyForKey:primaryKey fromDatas:item];
                                [tempKeys addObject:key];
                                [tempValues setObject:item forKey:key];
                            }
                            NSMutableArray *uniques = [NSMutableArray array];
                            for (id key in tempKeys) {
                                [uniques addObject:[tempValues objectForKey:key]];
                            }
                            
                            [objs removeAllObjects];
                            for (id item in uniques) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    id primaryValue = [[clazz alloc] propertyForKey:primaryKey fromDatas:item];
                                    id primaryExist = [clazz ar_objectForPrimaryKey:primaryValue];
                                    if (primaryExist) {
                                        [primaryExist updateDataCacheWithDataPartInTransaction:item];
                                        [objs addObject:primaryExist];
                                    } else {
                                        [objs addObject:[[clazz alloc] initDataCache:item]];
                                    }
                                }
                            }
                        } else {
                            [[self.class ar_defaultRealm] deleteObjects:objs];
                            for (id item in values) {
                                if ([item isKindOfClass:NSDictionary.class]) {
                                    [objs addObject:[[clazz alloc] initDataCache:item]];
                                }
                            }
                        }
                    } else if (objs.type == RLMPropertyTypeString ||
                               objs.type == RLMPropertyTypeBool ||
                               objs.type == RLMPropertyTypeInt ||
                               objs.type == RLMPropertyTypeFloat ||
                               objs.type == RLMPropertyTypeDouble ||
                               objs.type == RLMPropertyTypeDate ||
                               objs.type == RLMPropertyTypeData) {
                        [objs removeAllObjects];
                        [objs addObjects:value];
                    }
                }
            } else {
                [self setPropertyValue:value forKey:key];
            }
        }
    }];
    
    if ([self respondsToSelector:@selector(setValueForExtraProperties)]) {
        [self setValueForExtraProperties];
    }
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

