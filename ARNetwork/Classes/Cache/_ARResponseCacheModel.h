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

- (instancetype)initAndAddDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params responseObject:(id)responseObject;

- (void)updateDataCacheWithResponseObject:(id)responseObject;

- (id)responseObject;

@end
RLM_ARRAY_TYPE(ARResponseCacheModel)
