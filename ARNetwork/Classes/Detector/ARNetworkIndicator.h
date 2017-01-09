//
//  ARNetworkIndicator.h
//  ARNetwork
//
//  Created by Linzh on 1/9/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNetworkIndicator : NSObject

+ (instancetype)sharedInstance;

- (void)setActive:(BOOL)active;
@end
