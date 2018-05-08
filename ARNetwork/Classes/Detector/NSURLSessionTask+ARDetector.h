//
//  NSURLSessionTask+ARDetector.h
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/7.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (ARDetector)

/**
 Determine whether the activity of session task should be detected.
 */
@property (nonatomic, assign) BOOL ar_loadingDetective;

/**
 The super view of loading view if needed.
 */
@property (nonatomic, strong, nullable) UIView *ar_loadingSuperView;

- (void)ar_detectLoading;

- (void)ar_detectLoadingWithSuperView:(nullable UIView *)superView;

@end

NS_ASSUME_NONNULL_END
