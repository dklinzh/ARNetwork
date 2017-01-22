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
@property (nonatomic, assign, getter=isHttpDNSEnabled) BOOL httpDNSEnabled;

- (void)seAccountId:(NSInteger)accountId;

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts;

- (NSString *)getHostByIP:(NSString *)ip;

+ (NSString *)getIpURLByHostURL:(NSString *)hostUrl;

+ (NSString *)getIpURLByHostURL:(NSString *)hostUrl onDNS:(void(^)(NSString *host, NSString *ip))block;

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl;

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl onDNS:(void(^)(NSString *host, NSString *ip))block;
@end
