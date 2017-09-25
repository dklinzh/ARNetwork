//
//  ARHTTPConfiguration.h
//  ARNetwork
//
//  Created by Daniel Lin on 22/09/2017.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARHTTPRequestOperation <NSObject>

@optional
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;

@end

@interface ARHTTPConfiguration : NSObject

@property (nonatomic, weak) id<ARHTTPRequestOperation> httpRequestOperation;

+ (instancetype)sharedInstance;
@end

@interface ARHTTPConfiguration (RequestOperation) <ARHTTPRequestOperation>

@end
