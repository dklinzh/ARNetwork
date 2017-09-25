//
//  ARHTTPOperation.h
//  ARNetwork
//
//  Created by Linzh on 12/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ARRequestEncodedType) {
    ARRequestEncodedTypeDefault,
    ARRequestEncodedTypeJSON,
    ARRequestEncodedTypePlist,
};

@protocol ARHTTPRequestOperation <NSObject>

@optional

@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;

@property (nonatomic, assign, readonly) BOOL allowRequestRedirection;

@property (nonatomic, assign, readonly) ARRequestEncodedType requestEncodedType;

@property (nonatomic, strong, readonly, nullable) NSOrderedSet<Class> *protocolClasses;

@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, id> *extraHTTPHeaders;

- (NSString *)processedRequestURL:(NSString *)urlStr;

- (NSString *)taskKeyForRequestURL:(NSString *)urlStr params:(NSDictionary *)params;

@end

typedef void(^ARHTTPResponseSuccess)(id data,  NSString * _Nullable msg);
typedef void(^ARHTTPResponseFailure)(NSInteger code, NSString * _Nullable msg);
typedef void(^ARHTTPResponseHead)(NSURLSessionDataTask *task);

@protocol ARHTTPResponseOperation <NSObject>

@optional

@property (nonatomic, strong, readonly, nullable) NSSet<NSString *> *extraContentTypes;

- (void)responseSuccess:(ARHTTPResponseSuccess)success orFailure:(ARHTTPResponseFailure)failure withData:(id)data;

- (void)responseFailure:(ARHTTPResponseFailure)failure withError:(NSError *)error;

@end

@interface ARHTTPOperation : NSObject

@property (nonatomic, weak, nullable) id<ARHTTPRequestOperation> requestOperation;

@property (nonatomic, weak, nullable) id<ARHTTPResponseOperation> responseOperation;

+ (instancetype)sharedInstance;

+ (instancetype)defaultOperation;

@end

@interface ARHTTPOperation (Request) <ARHTTPRequestOperation>

@end

@interface ARHTTPOperation (Response) <ARHTTPResponseOperation>

@end

NS_ASSUME_NONNULL_END
