//
//  ARHTTPMock.h
//  ARNetwork
//
//  Created by Daniel Lin on 16/11/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.

#ifdef DEBUG

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARHTTPMock : NSObject

+ (void)setEnabled:(BOOL)enabled;

+ (void)removeAllMocks;

+ (void)getRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName;

+ (void)postRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName;

+ (void)putRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName;

+ (void)patchRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName;

+ (void)deleteRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName;

+ (void)headRequestURL:(NSString *)urlString responseByMainBundleJSONFile:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END

#endif
