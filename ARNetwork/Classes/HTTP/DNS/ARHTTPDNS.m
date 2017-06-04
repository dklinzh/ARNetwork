//
//  ARHTTPDNS.m
//  ARNetwork
//
//  Created by Linzh on 12/23/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARHTTPDNS.h"
#import <AlicloudHttpDNS/AlicloudHttpDNS.h> //* https://help.aliyun.com/document_detail/30141.html

static NSString *const kARDNSMapUserDefaultsKey = @"kARDNSMapUserDefaultsKey";

@interface ARHTTPDNS () <HttpDNSDegradationDelegate>
@property (nonatomic, copy) NSArray *ignoredHosts;
@property (nonatomic, assign) BOOL dnsLogEnabled;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *dnsMap;
@end

@implementation ARHTTPDNS
static ARHTTPDNS *sharedInstance = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.dnsLogEnabled = NO;
        [[HttpDnsService sharedInstance] setHTTPSRequestEnabled:YES];
        [[HttpDnsService sharedInstance] setExpiredIPEnabled:YES];
        [[HttpDnsService sharedInstance] setPreResolveAfterNetworkChanged:YES];
//        [HttpDnsService sharedInstance].timeoutInterval = 30;
    }
    return self;
}

- (NSString *)getIpByHostAsync:(NSString *)host {
    if (!self.isHttpDNSEnabled) {
        return host ? host : nil;
    }
    
    NSString *ip = [[HttpDnsService sharedInstance] getIpByHostAsync:host];
    if (!ip) {
        ip = [self.dnsMap allKeysForObject:host].firstObject;
    }
    if (!ip) {
        return host;
    }
    
    if (![ip isEqualToString:host]) {
        [self setDNSMapWithHost:host ip:ip];
    }
    
    if (self.dnsLogEnabled) {
        ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ip);
    }
    return ip;
}

- (NSArray *)getIpsByHostAsync:(NSString *)host {
    if (!self.isHttpDNSEnabled) {
        return host ? @[host] : nil;
    }

    NSArray *ips = [[HttpDnsService sharedInstance] getIpsByHostAsync:host];
    if (!ips) {
        ips = [self.dnsMap allKeysForObject:host];
    }
    if (!ips) {
        return @[host];
    }
    
    for (NSString *ip in ips) {
        if ([ip isEqualToString:host]) {
            continue;
        }
        [self setDNSMapWithHost:host ip:ip];
    }
    
    if (self.dnsLogEnabled) {
        ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ips);
    }
    return ips;
}

- (NSString *)getIpByHostAsyncInURLFormat:(NSString *)host {
    if (!self.isHttpDNSEnabled) {
        return host ? host : nil;
    }
    
    NSString *ip = [[HttpDnsService sharedInstance] getIpByHostAsyncInURLFormat:host];
    if (!ip) {
        ip = [self.dnsMap allKeysForObject:host].firstObject;
    }
    if (!ip) {
        return host;
    }
    
    if (![ip isEqualToString:host]) {
        [self setDNSMapWithHost:host ip:ip];
    }
    
    if (self.dnsLogEnabled) {
        ARLogInfo(@"<HTTPDNS> %@ -> %@", host, ip);
    }
    return ip;
}

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl {
    return [self getIpURLByHostURLAsync:hostUrl onDNS:nil];
}

+ (NSString *)getIpURLByHostURLAsync:(NSString *)hostUrl onDNS:(void(^)(NSString *host, NSString *ip))block {
    if (![[self sharedInstance] isHttpDNSEnabled]) {
        return hostUrl;
    }
    
    NSURL *url = [NSURL URLWithString:hostUrl];
    NSString *host = url.host;
    if (!host) {
        return hostUrl;
    }
    
    NSString *ip = [[self sharedInstance] getIpByHostAsyncInURLFormat:host];
    if (ip && ![ip isEqualToString:host]) {
        if (block) {
            block(host, ip);
        }
        
        NSRange hostFirstRange = [hostUrl rangeOfString: host];
        if (hostFirstRange.location != NSNotFound) {
            NSString* ipUrl = [hostUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            return ipUrl;
        }
    }
    
    if (block) {
        block(host, nil);
    }
    return hostUrl;
}

- (void)seAccountId:(NSInteger)accountId {
    [HttpDnsService sharedInstance].accountID = (int)accountId;
    self.httpDNSEnabled = YES;
}

- (void)setDnsLogEnabled:(BOOL)dnsLogEnabled {
    _dnsLogEnabled = dnsLogEnabled;
    [[HttpDnsService sharedInstance] setLogEnabled:dnsLogEnabled];
}

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts {
    [[HttpDnsService sharedInstance] setPreResolveHosts:preResolveHosts];
    if ((self.ignoredHosts = ignoredHosts)) {
        [[HttpDnsService sharedInstance] setDelegateForDegradationFilter:self];
    } else {
        [[HttpDnsService sharedInstance] setDelegateForDegradationFilter:nil];
    }
}

- (NSString *)getHostByIP:(NSString *)ip {
    return [self.dnsMap valueForKey:ip];
}

#pragma mark -

- (void)setDNSMapWithHost:(NSString *)host ip:(NSString *)ip {
    if (![[self.dnsMap valueForKey:ip] isEqualToString:host]) {
        [self.dnsMap setValue:host forKey:ip];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.dnsMap forKey:kARDNSMapUserDefaultsKey];
        [defaults synchronize];
    }
}

- (NSMutableDictionary<NSString *,NSString *> *)dnsMap {
    if (_dnsMap) {
        return _dnsMap;
    }
    return _dnsMap = [[[NSUserDefaults standardUserDefaults] objectForKey:kARDNSMapUserDefaultsKey] mutableCopy] ?: [NSMutableDictionary dictionary];
}

#pragma mark - HttpDNSDegradationDelegate
- (BOOL)shouldDegradeHTTPDNS:(NSString *)hostName {
    if ([self.ignoredHosts containsObject:hostName]) {
        if (self.dnsLogEnabled) {
            ARLogWarn(@"<HTTPDNS> %@ -> ignored", hostName);
        }
        return YES;
    }
    return NO;
}
@end
