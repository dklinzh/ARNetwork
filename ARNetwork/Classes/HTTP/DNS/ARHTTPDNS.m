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
@property (nonatomic, strong) HttpDnsService *httpDNSService;
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
        _dnsLogEnabled = NO;
    }
    return self;
}

- (NSString *)getIpByHostAsync:(NSString *)host {
    if (!self.isHttpDNSEnabled) {
        return host ? host : nil;
    }
    
    NSString *ip = [self.httpDNSService getIpByHostAsync:host];
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

    NSArray *ips = [self.httpDNSService getIpsByHostAsync:host];
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
    
    NSString *ip = [self.httpDNSService getIpByHostAsyncInURLFormat:host];
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

- (void)seAccountID:(NSInteger)accountID {
    [self seAccountID:accountID secret:nil];
}

- (void)seAccountID:(NSInteger)accountID secret:(NSString *)secret {
    self.httpDNSService = secret ? [[HttpDnsService alloc] initWithAccountID:(int)accountID secretKey:secret] : [[HttpDnsService alloc] initWithAccountID:(int)accountID];
    [self.httpDNSService setHTTPSRequestEnabled:YES];
    [self.httpDNSService setExpiredIPEnabled:YES];
    [self.httpDNSService setPreResolveAfterNetworkChanged:YES];
    //        self.httpDNSService.timeoutInterval = 30;
    
    self.httpDNSEnabled = YES;
}

- (void)setDnsLogEnabled:(BOOL)dnsLogEnabled {
    _dnsLogEnabled = dnsLogEnabled;
    [self.httpDNSService setLogEnabled:dnsLogEnabled];
}

- (void)setPreResolveHosts:(NSArray *)preResolveHosts ignoreddHosts:(NSArray *)ignoredHosts {
    [self.httpDNSService setPreResolveHosts:preResolveHosts];
    if ((self.ignoredHosts = ignoredHosts)) {
        [self.httpDNSService setDelegateForDegradationFilter:self];
    } else {
        [self.httpDNSService setDelegateForDegradationFilter:nil];
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
