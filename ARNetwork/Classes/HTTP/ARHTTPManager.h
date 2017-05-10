//
//  ARHTTPManager.h
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ARHTTPOperation.h"

/**
 A basic session manager whit some HTTP operations.
 */
@interface ARHTTPManager : AFHTTPSessionManager

/**
 The timeout interval for creating request, in seconds. Defaults to 30 s.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *acceptableContentTypes;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *taskCollections;
@property (nonatomic, strong) ARHTTPOperation *httpOperation;
@property (nonatomic, assign) BOOL allowRequestRedirection;

+ (void)registerProtocolClass:(Class)protocolClass;

+ (void)unregisterProtocolClass:(Class)protocolClass;

+ (instancetype)sharedInstance;

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePaths:(NSArray<NSString *> *)filePaths formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure;
@end
