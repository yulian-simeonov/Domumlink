//
//  NetworkDataFetcher.h
//  ExLib
//
//  Created by Yulian Simeonov Bogdan on 1/9/14.
//  Copyright (c) 2014 ExLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetworkDataClient : AFHTTPSessionManager

@property (nonatomic, strong) NSString *rootURL;
+ (NetworkDataClient *)mainFetcher;

- (id)initWithBaseURL:(NSString *)url;
- (NSData *)executeImmediate:(NSURL *)url;

- (void)fetchJson:(NSString *)urlString  withData:(NSDictionary *)getData withSuccessHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;
- (void)postTo:(NSString *)urlString withData:(NSDictionary *)postData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

- (void)putTo:(NSString *)urlString withData:(NSDictionary *)postData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

- (void)delete:(NSString *)urlString withData:(NSDictionary *)queryData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// Uploading
-(void)uploadTo:(NSString *)urlString withData:(NSDictionary *)postData withMPFDHandler: (void (^)(id<AFMultipartFormData> formData))dataHandler withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

-(void)uploadTo:(NSString *)urlString withData:(NSDictionary *)postData withFileInfo:(NSDictionary *)fileData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// Upload with progress block
-(void)uploadTo:(NSString *)urlString withData:(NSDictionary *)postData withFileInfo:(NSDictionary *)fileData withSuccessHandler:(void (^) (id responseObject))successHandler withProgressHandler:(void(^) (NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// Handlers
-(void)handleFailure:(NSError *)error withResponse:(NSURLResponse *)response withFailureHandler:(void (^) (NSError *err))failureHandler;


+ (void)showAlertFailure:(NSError *)err;
+ (void)showAlertFailure:(NSError *)err fromResponse:(NSURLResponse *)response withTitle:(NSString *)title;

- (void)callLoginApi;
@end
