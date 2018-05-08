//
//  NSURLSessionTask+ARHTTP.h
//  ARNetwork
//
//  Created by Daniel Lin on 19/03/2018.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (ARHTTP)

/**
 Determine whether the manager should cancel the `duplicated` task before the next one resume.
 */
@property (nonatomic, assign) BOOL ar_shouldCancelDuplicatedTask;

/**
 The unique ID of NSURLSessionTask
 */
@property (nonatomic, copy) NSString *ar_taskID;

@end

NS_ASSUME_NONNULL_END
