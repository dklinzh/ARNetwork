//
//  _ARResponseCacheModel.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"

@interface _ARResponseCacheModel : ARDataCacheModel
@property NSData *_AR_RESPONSE_DATA;

- (instancetype)initAndAddDataCache:(id)responseObject forKey:(NSString *)cacheKey;

- (void)updateDataCacheWithResponseObject:(id)responseObject;

- (id)responseObject;

@end
RLM_ARRAY_TYPE(ARResponseCacheModel)
