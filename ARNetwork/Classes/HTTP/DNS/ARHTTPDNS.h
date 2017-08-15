//
//  ARHTTPDNS.h
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARHTTPDNS : NSObject
@property (nonatomic, assign, getter=isHttpDNSEnabled) BOOL httpDNSEnabled;

+ (instancetype)sharedInstance;

- (void)seAccountID:(NSInteger)accountID;

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts;

- (nullable NSString *)getIpByHostAsync:(NSString *)host;

- (nullable NSArray *)getIpsByHostAsync:(NSString *)host;

- (nullable NSString *)getIpByHostAsyncInURLFormat:(NSString *)host;

- (nullable NSString *)getHostByIP:(NSString *)ip;

+ (nullable NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl;

+ (nullable NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl onDNS:(nullable void(^)(NSString *host, NSString * _Nullable ip))block;
@end

NS_ASSUME_NONNULL_END
