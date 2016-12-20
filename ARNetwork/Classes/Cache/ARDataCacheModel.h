//
//  ARDataCacheModel.h
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Realm/Realm.h>

@interface ARDataCacheModel : RLMObject
@property NSString *arHost;
@property NSString *arPath;
@property NSString *arParams;
@property NSDate *arTime;

//+ (instancetype)initWithData:(NSDictionary *)data;

+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;

- (void)addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params;

- (void)updateDataCacheWithData:(NSDictionary *)data;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<ARDataCacheModel>
RLM_ARRAY_TYPE(ARDataCacheModel)
