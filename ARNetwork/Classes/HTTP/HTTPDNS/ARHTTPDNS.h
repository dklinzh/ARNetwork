//
//  ARHTTPDNS.h
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlicloudHttpDNS.h" //* https://help.aliyun.com/document_detail/30141.html

@interface ARHTTPDNS : HttpDnsService
- (void)seAccountId:(NSInteger)accountId;

- (void)setHttpDNSEnabled:(BOOL)httpDNSEnabled;

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts;

+ (NSString *)getIpByHost:(NSString *)host;

+ (NSArray *)getIpsByHost:(NSString *)host;

+ (NSString *)getIpByHostInURLFormat:(NSString *)host;

+ (NSString *)getIpByHostAsync:(NSString *)host;

+ (NSArray *)getIpsByHostAsync:(NSString *)host;

+ (NSString *)getIpByHostAsyncInURLFormat:(NSString *)host;
@end
