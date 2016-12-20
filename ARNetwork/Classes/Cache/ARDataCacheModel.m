//
//  ARDataCacheModel.m
//  ARNetwork
//
//  Created by Linzh on 12/15/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "ARDataCacheModel.h"

@implementation ARDataCacheModel

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

//+ (instancetype)initWithData:(NSDictionary *)data {
//    SEL selector = NSSelectorFromString(@"initWithValue:");
//    id object = [self alloc];
//    if ([object respondsToSelector:selector]) {
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:selector]];
//        [invocation setTarget:object];
//        [invocation setSelector:selector];
//        [invocation setArgument:&data atIndex:2];
//        [invocation invoke];
//        [invocation getReturnValue:&object];
//        return object;
//    } else {
//        return nil;
//    }
//}

+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"arHost = %@ AND arPath = %@ AND arParams = %@", url.host, url.path, params.description];
    RLMResults *caches = [[self class] objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}

- (void)addDataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    if (!self.isInvalidated) {
        NSURL *url = [NSURL URLWithString:urlStr];
        self.arHost = url.host;
        self.arPath = url.path;
        self.arParams = params.description;
        self.arTime = [NSDate dateWithTimeIntervalSinceNow:0];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] addObject:self];
        }];
    }
}

- (void)updateDataCacheWithData:(NSDictionary *)data {
    if (!self.isInvalidated) {
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            self.arTime = [NSDate dateWithTimeIntervalSinceNow:0];
            for (NSString *key in data.allKeys) {
                if ([self respondsToSelector:NSSelectorFromString(key)]) {
                    [self setValue:data[key] forKey:key];
                }
            }
        }];
    }
}
@end
