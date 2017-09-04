//
//  ARHTTPManager.h
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ARHTTPOperation.h"

typedef NS_ENUM(NSUInteger, ARRequestEncodedType) {
    ARRequestEncodedTypeDefault,
    ARRequestEncodedTypeJSON,
    ARRequestEncodedTypePlist,
};

NS_ASSUME_NONNULL_BEGIN

/**
 A basic session manager whit some HTTP operations.
 */
@interface ARHTTPManager : AFHTTPSessionManager

/**
 The timeout interval for creating request, in seconds. Defaults to 30 s.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 The extra acceptable MIME types for responses. When non-`nil`, responses with a `Content-Type` with MIME types that do not intersect with the set will result in an error during validation.
 */
@property (nonatomic, copy) NSSet<NSString *> *extraContentTypes;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *taskCollections;
@property (nonatomic, strong) ARHTTPOperation *httpOperation;
@property (nonatomic, assign) BOOL allowRequestRedirection;

@property (nonatomic, assign) ARRequestEncodedType requestEncodedType;

+ (void)registerProtocolClass:(Class)protocolClass;

+ (void)unregisterProtocolClass:(Class)protocolClass;

+ (instancetype)sharedInstance;

/**
 Set HTTP header fields for the HTTP manager

 @param headers The dictionary of header fields
 */
- (void)setHTTPHeaders:(NSDictionary *)headers;

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(nullable NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseSuccess)success failure:(nullable ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseHead)success failure:(nullable ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(nullable NSDictionary *)params success:(nullable ARHTTPResponseHead)success failure:(nullable ARHTTPResponseFailure)failure;

@end

@interface ARHTTPManager (Session)

- (nullable NSString *)getJSESSIONIDForURL:(NSString *)urlString;

- (void)restoreSession:(NSString *)JSESSIONID forURL:(NSString *)urlString;

- (void)setHTTPHeaderWithAuthorization:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
