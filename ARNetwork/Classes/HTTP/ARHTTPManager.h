//
//  ARHTTPManager.h
//  ARNetwork
//
//  Created by Linzh on 12/13/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ARHTTPOperation.h"

@interface ARHTTPManager : AFHTTPSessionManager
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *acceptableContentTypes;
@property (nonatomic, weak) ARHTTPOperation *httpOperation;

+ (instancetype)sharedInstance;

+ (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)getURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)postURL:(NSString *)urlStr params:(NSDictionary *)params filePath:(NSString *)filePath formName:(NSString *)formName progress:(void (^)(NSProgress *uploadProgress))uploadProgress success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)putURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)patchURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)deleteURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseSuccess)success failure:(ARHTTPResponseFailure)failure;

+ (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure;

- (NSURLSessionDataTask *)headURL:(NSString *)urlStr params:(NSDictionary *)params success:(ARHTTPResponseHead)success failure:(ARHTTPResponseFailure)failure;
@end
