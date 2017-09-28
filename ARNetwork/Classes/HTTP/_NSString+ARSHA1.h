//
//  _NSString+ARSHA1.h
//  ARNetwork
//
//  Created by Linzh on 2/10/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ARSHA1)

- (NSString *)ar_SHA1;
@end

static inline NSString * ar_sessionTaskKey(NSString *urlStr, NSDictionary *params) {
    NSURL *url = [NSURL URLWithString:urlStr];
    return [[NSString stringWithFormat:@"%@|%@|%@", url.host, url.path, params.description] ar_SHA1];
}
