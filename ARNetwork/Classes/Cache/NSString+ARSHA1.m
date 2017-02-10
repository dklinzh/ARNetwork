//
//  NSString+ARSHA1.m
//  ARNetwork
//
//  Created by Linzh on 2/10/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "NSString+ARSHA1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ARSHA1)

- (NSString *)ar_SHA1 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}
@end
