//
//  ARNetworkIndicator.m
//  ARNetwork
//
//  Created by Linzh on 1/9/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "ARNetworkIndicator.h"
#import "NSURLSessionTask+ARDetector.h"
#import "ARHTTPOperation.h"
#import <AFNetworking/AFURLSessionManager.h>

@interface AFNetworkActivityIndicatorManager()
- (void)networkRequestDidStart:(NSNotification *)notification;
- (void)networkRequestDidFinish:(NSNotification *)notification;
@end

@interface ARNetworkIndicator()
@property (nonatomic, copy) ARNetworkLoadingStartBlock networkLoadingStartBlock;
@property (nonatomic, copy) ARNetworkLoadingFinishBlock networkLoadingFinishBlock;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *superViewLoadingCounts;
@end

@implementation ARNetworkIndicator

- (void)detectNetworkLoadingWithStart:(ARNetworkLoadingStartBlock)startBlock finish:(ARNetworkLoadingFinishBlock)finishBlock {
    self.enabled = YES;
    self.networkLoadingStartBlock = startBlock;
    self.networkLoadingFinishBlock = finishBlock;
}

- (void)networkRequestDidStart:(NSNotification *)notification {
    [super networkRequestDidStart:notification];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.networkLoadingStartBlock) {
            NSURLSessionTask *task = notification.object;
            if (task.ar_loadingDetective) {
                UIView *superView = task.ar_loadingSuperView;
                if (superView) {
                    NSInteger loadingCount = 0;
                    NSNumber *key = @(superView.hash);
                    NSNumber *value = self.superViewLoadingCounts[key];
                    if (value) {
                        loadingCount = value.integerValue;
                    }
                    self.superViewLoadingCounts[key] = @(++loadingCount);
                    if (loadingCount == 1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.networkLoadingStartBlock(superView);
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.networkLoadingStartBlock(nil);
                    });
                }
            }
        }
    });
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    [super networkRequestDidFinish:notification];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.networkLoadingFinishBlock) {
            NSURLSessionTask *task = notification.object;
            if (task.ar_loadingDetective) {
                NSInteger loadingCount = 0;
                UIView *superView = task.ar_loadingSuperView;
                if (superView) {
                    NSNumber *key = @(superView.hash);
                    NSNumber *value = self.superViewLoadingCounts[key];
                    if (value) {
                        loadingCount = value.integerValue;
                        if (--loadingCount <= 0) {
                            [self.superViewLoadingCounts removeObjectForKey:key];
                        } else {
                            self.superViewLoadingCounts[key] = @(loadingCount);
                        }
                    }
                }
                
                NSDictionary *userInfo = notification.userInfo;
                NSError *error = userInfo[AFNetworkingTaskDidCompleteErrorKey];
                if (error) {
                    if (loadingCount <= 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.networkLoadingFinishBlock(superView, ARNetworkLoadingFinishedStateFailure);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.networkLoadingFinishBlock(superView, ARNetworkLoadingFinishedStateUnknown);
                        });
                    }
                } else {
                    id responseObject = userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
                    [ARHTTPOperation.sharedInstance responseSuccess:^(id  _Nonnull data, NSString * _Nullable msg) {
                        if (loadingCount <= 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.networkLoadingFinishBlock(superView, ARNetworkLoadingFinishedStateSuccess);
                            });
                        }
                    } orFailure:^(NSInteger code, NSString * _Nullable msg) {
                        if (loadingCount <= 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.networkLoadingFinishBlock(superView, ARNetworkLoadingFinishedStateFailure);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.networkLoadingFinishBlock(superView, ARNetworkLoadingFinishedStateUnknown);
                            });
                        }
                    } withData:responseObject];
                }
            }
        }
    });
}

- (NSMutableDictionary<NSNumber *,NSNumber *> *)superViewLoadingCounts {
    @synchronized(self) {
        if (_superViewLoadingCounts) {
            return _superViewLoadingCounts;
        }
        
        return _superViewLoadingCounts = [NSMutableDictionary dictionary];
    }
}

@end
