//
//  ARNetworkIndicator.h
//  ARNetwork
//
//  Created by Linzh on 1/9/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

typedef NS_ENUM(NSInteger, ARNetworkLoadingFinishedState) {
    ARNetworkLoadingFinishedStateUnknown,
    ARNetworkLoadingFinishedStateSuccess,
    ARNetworkLoadingFinishedStateFailure,
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^ARNetworkLoadingStartBlock)(UIView * _Nullable loadingSuperView);
typedef void(^ARNetworkLoadingFinishBlock)(UIView * _Nullable loadingSuperView, ARNetworkLoadingFinishedState loadingFinishedState);

@interface ARNetworkIndicator : AFNetworkActivityIndicatorManager

- (void)detectNetworkLoadingWithStart:(ARNetworkLoadingStartBlock)startBlock finish:(ARNetworkLoadingFinishBlock)finishBlock;

@end

NS_ASSUME_NONNULL_END
