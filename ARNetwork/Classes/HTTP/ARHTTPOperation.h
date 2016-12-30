//
//  ARHTTPOperation.h
//  ARNetwork
//
//  Created by Linzh on 12/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARHTTPRequestDelegate <NSObject>

@optional
- (NSString *)ar_taskKeyForRequestURL:(NSString *)urlStr params:(NSDictionary *)params;

@end

typedef void(^ARHTTPResponseSuccess)(id data, NSString *msg);
typedef void(^ARHTTPResponseFailure)(NSInteger code, NSString *msg);
typedef void(^ARHTTPResponseHead)(NSURLSessionDataTask *task);

@protocol ARHTTPResponseDelegate <NSObject>

@required
- (void)ar_onSuccess:(ARHTTPResponseSuccess)success onFailure:(ARHTTPResponseFailure)failure withData:(id)data;
- (void)ar_onFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error;

@end

@interface ARHTTPOperation : NSObject <ARHTTPRequestDelegate, ARHTTPResponseDelegate>

@end
