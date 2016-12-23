//
//  ARHTTPDNS.m
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPDNS.h"

@interface ARHTTPDNS () <HttpDNSDegradationDelegate>
@property (nonatomic, assign) BOOL httpDNSEnabled;
@property (nonatomic, strong) NSArray *ignoredHosts;
@end

@implementation ARHTTPDNS

#pragma mark - Override
- (instancetype)init {
    if (self = [super init]) {
        self.httpDNSEnabled = YES;
        [self setLogEnabled:YES];
        [self setHTTPSRequestEnabled:NO];
        [self setExpiredIPEnabled:YES];
        [self setPreResolveAfterNetworkChanged:NO];
    }
    return self;
}

- (NSString *)getIpByHost:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host;
    }
    
    NSString *ip = [super getIpByHost:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ip);
    return ip;
}

- (NSArray *)getIpsByHost:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host ? @[host] : nil;
    }
    
    NSArray *ips = [super getIpsByHost:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ips);
    return ips;
}

- (NSString *)getIpByHostInURLFormat:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host;
    }
    
    NSString *ip = [super getIpByHostInURLFormat:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ip);
    return ip;
}

- (NSString *)getIpByHostAsync:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host;
    }
    
    NSString *ip = [super getIpByHostAsync:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ip);
    return ip;
}

- (NSArray *)getIpsByHostAsync:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host ? @[host] : nil;
    }

    NSArray *ips = [super getIpsByHostAsync:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ips);
    return ips;
}

- (NSString *)getIpByHostAsyncInURLFormat:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host;
    }
    
    NSString *ip = [super getIpByHostAsyncInURLFormat:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ip);
    return ip;
}

#pragma mark -
+ (NSString *)getIpByHost:(NSString *)host {
    return [[self sharedInstance] getIpByHost:host];
}

+ (NSArray *)getIpsByHost:(NSString *)host {
    return [[self sharedInstance] getIpsByHost:host];
}

+ (NSString *)getIpByHostInURLFormat:(NSString *)host {
    return [[self sharedInstance] getIpByHostInURLFormat:host];
}

+ (NSString *)getIpByHostAsync:(NSString *)host {
    return [[self sharedInstance] getIpByHostAsync:host];
}

+ (NSArray *)getIpsByHostAsync:(NSString *)host {
    return [[self sharedInstance] getIpsByHostAsync:host];
}

+ (NSString *)getIpByHostAsyncInURLFormat:(NSString *)host {
    return [[self sharedInstance] getIpByHostAsyncInURLFormat:host];
}

- (void)seAccountId:(NSInteger)accountId {
    self.accountID = accountId;
}

- (void)setHttpDNSEnabled:(BOOL)httpDNSEnabled {
    _httpDNSEnabled = httpDNSEnabled;
}

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts {
    [self setPreResolveHosts:preResolveHosts];
    if ((self.ignoredHosts = ignoredHosts)) {
        [self setDelegateForDegradationFilter:self];
    } else {
        [self setDelegateForDegradationFilter:nil];
    }
}

#pragma mark - HttpDNSDegradationDelegate
- (BOOL)shouldDegradeHTTPDNS:(NSString *)hostName {
    if ([self.ignoredHosts containsObject:hostName]) {
        ARLogWarn(@"<HTTPDNS> %@ -> ignored", hostName);
        return YES;
    }
    return NO;
}
@end
