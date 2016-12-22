//
//  ARHTTPResponse.h
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ARHTTPResponseSuccess)(id data, NSString *msg);
typedef void(^ARHTTPResponseFailure)(NSInteger code, NSString *msg);
typedef void(^ARHTTPResponseHead)(NSURLSessionDataTask *task);

@protocol ARHTTPResponseDelegate <NSObject>

@required
- (void)ar_onSuccess:(ARHTTPResponseSuccess)success onFailure:(ARHTTPResponseFailure)failure withData:(id)data;
- (void)ar_onFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error;

@end

@interface ARHTTPResponse : NSObject <ARHTTPResponseDelegate>

@end
