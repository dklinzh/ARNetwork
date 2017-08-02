//
//  ARHTTPDNS.h
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARHTTPDNS : NSObject
@property (nonatomic, assign, getter=isHttpDNSEnabled) BOOL httpDNSEnabled;

+ (instancetype)sharedInstance;

- (void)seAccountId:(NSInteger)accountID;

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts;

- (NSString *)getIpByHostAsync:(NSString *)host;

- (NSArray *)getIpsByHostAsync:(NSString *)host;

- (NSString *)getIpByHostAsyncInURLFormat:(NSString *)host;

- (NSString *)getHostByIP:(NSString *)ip;

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl;

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl onDNS:(void(^)(NSString *host, NSString *ip))block;
@end
