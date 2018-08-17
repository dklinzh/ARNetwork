//
//  ARMultiUserDataCacheManager.h
//  ARNetwork
//
//  Created by Daniel Lin on 2018/8/14.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

#import "ARDataCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARMultiUserDataCacheManager : ARDataCacheManager

- (void)switchUserDataWithAccount:(NSString *)account completion:(nullable void(^)(void))completion;

- (void)clearUserDataCacheWithAccount:(NSString *)account;

- (void)clearUserDataCache;
@end

NS_ASSUME_NONNULL_END
