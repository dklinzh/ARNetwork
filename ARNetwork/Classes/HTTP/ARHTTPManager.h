//
//  ARHTTPManager.h
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ARHTTPOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A basic session manager whit some HTTP operations.
 */
@interface ARHTTPManager : AFHTTPSessionManager

@property (nonatomic, strong, readonly) ARHTTPOperation *operation;

- (instancetype)initWithHTTPOperation:(ARHTTPOperation *)operation;

- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration httpOperation:(ARHTTPOperation *)operation NS_DESIGNATED_INITIALIZER;

+ (instancetype)sharedInstance __attribute__ ((deprecated));

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

- (nullable NSString *)JSESSIONIDForURL:(NSString *)urlString;

- (void)restoreSession:(NSString *)JSESSIONID forURL:(NSString *)urlString;

- (void)setHTTPHeaderWithAuthorization:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
