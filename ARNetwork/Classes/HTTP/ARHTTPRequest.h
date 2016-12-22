//
//  ARHTTPRequest.h
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARHTTPRequestDelegate <NSObject>

@optional
- (NSString *)ar_taskKeyForRequestURL:(NSString *)urlStr;

@end

@interface ARHTTPRequest : NSObject <ARHTTPRequestDelegate>

@end
