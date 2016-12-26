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
//        self.httpDNSEnabled = YES;
        [self setLogEnabled:NO];
        [self setHTTPSRequestEnabled:NO];
        [self setExpiredIPEnabled:YES];
        [self setPreResolveAfterNetworkChanged:NO];
    }
    return self;
}

- (NSArray *)getIpsByHost:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host ? @[host] : nil;
    }
    
    NSArray *ips = [super getIpsByHost:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ips);
    return ips;
}

- (NSArray *)getIpsByHostAsync:(NSString *)host {
    if (!self.httpDNSEnabled) {
        return host ? @[host] : nil;
    }

    NSArray *ips = [super getIpsByHostAsync:host];
    ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ips);
    return ips;
}

#pragma mark -

+ (NSString *)getIpURLByHostURL:(NSString *)hostUrl {
    if (![[self sharedInstance] httpDNSEnabled]) {
        return hostUrl;
    }
    
    NSURL *url = [NSURL URLWithString:hostUrl];
    NSString *host = url.host;
    if (!host) {
        return hostUrl;
    }
    
    NSString *ip = [[self sharedInstance] getIpByHostInURLFormat:host];
    if (ip) {
        NSRange hostFirstRange = [hostUrl rangeOfString: host];
        if (hostFirstRange.location != NSNotFound) {
            NSString* ipUrl = [hostUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            return ipUrl;
        }
    }
    return hostUrl;
}

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl {
    if (![[self sharedInstance] httpDNSEnabled]) {
        return hostUrl;
    }
    
    NSURL *url = [NSURL URLWithString:hostUrl];
    NSString *host = url.host;
    if (!host) {
        return hostUrl;
    }
    
    NSString *ip = [[self sharedInstance] getIpByHostAsyncInURLFormat:host];
    if (ip) {
        NSRange hostFirstRange = [hostUrl rangeOfString: host];
        if (hostFirstRange.location != NSNotFound) {
            NSString* ipUrl = [hostUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            return ipUrl;
        }
    }
    return hostUrl;
}

- (void)seAccountId:(NSInteger)accountId {
    self.accountID = accountId;
}

- (void)setAccountID:(int)accountID {
    [super setAccountID:accountID];
    self.httpDNSEnabled = YES;
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
