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

#pragma mark -
+ (instancetype)dataCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"arHost = %@ AND arPath = %@ AND arParams = %@", url.host, url.path, params.description];
    RLMResults<__kindof ARDataCacheModel *> *caches = [self.class objectsWithPredicate:pred];
    return caches.count > 0 ? caches.lastObject : nil;
}
@end
