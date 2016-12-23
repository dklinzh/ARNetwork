//
//  ARResponseCacheModel.h
//  ARNetwork
//
//  Created by Linzh on 12/22/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"

@interface ARResponseCacheModel : ARDataCacheModel
@property NSData *arResponseData;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ARDataCacheModel>
RLM_ARRAY_TYPE(ARResponseCacheModel)
