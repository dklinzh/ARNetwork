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
@property NSDate *arExpiredTime;

+ (NSArray *)valueUpdatedProperties;

- (instancetype)initDataCacheWithData:(NSDictionary *)data;

- (void)updateDataCacheWithData:(NSDictionary *)data;

- (void)setValueForExtraProperties NS_REQUIRES_SUPER;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<ARDataCacheModel>
RLM_ARRAY_TYPE(ARDataCacheModel)
