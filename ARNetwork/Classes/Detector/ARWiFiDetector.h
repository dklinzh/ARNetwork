//
//  ARWiFiDetector.h
//  ARNetwork
//
//  Created by Linzh on 1/6/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARWiFiDetector : NSObject

- (NSString *)localIP;

- (NSDictionary *)currentNetworkInfo;

- (BOOL)isWiFiConnected;
@end
