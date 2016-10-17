//
//  NetworkDataFetcher.m
//  ExLib
//
//  Created by Yulian Simeonov Bogdan on 1/9/14.
//  Copyright (c) 2014 ExLib. All rights reserved.
//

#import "NetworkDataClient.h"
#import "JSONResponseSerializerWithData.h"
#import "AppDelegate.h"

@implementation NetworkDataClient
@synthesize rootURL;

+(NetworkDataClient *)mainFetcher
{
    static NetworkDataClient *mainFetcher;
    
    if(mainFetcher == nil)
    {
        mainFetcher = [[NetworkDataClient alloc] initWithBaseURL:@""];
		mainFetcher.responseSerializer = [JSONResponseSerializerWithData serializerWithReadingOptions:NSJSONReadingMutableContainers];
    }
    
    return mainFetcher;
}

- (id)initWithBaseURL:(NSString *)url
{
    self = [super initWithBaseURL:[NSURL URLWithString:url]];
    [self setRootURL:url];
    
    return self;
}

- (NSData *)executeImmediate:(NSURL *)url{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    return responseData;
}

- (void)fetchJson:(NSString *)urlString  withData:(NSDictionary *)getData withSuccessHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    [self GET:urlString parameters:getData success:^(NSURLSessionDataTask *task, id responseObject) {
        successHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleFailure:error withResponse:task.response withFailureHandler:failureHandler];
    }];
}

- (void)postTo:(NSString *)urlString withData:(NSDictionary *)postData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    [self POST:urlString parameters:postData success:^(NSURLSessionDataTask *task, id responseObject) {
        successHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleFailure:error withResponse:task.response withFailureHandler:failureHandler];
    }];
}

-(void)uploadTo:(NSString *)urlString withData:(NSDictionary *)postData withMPFDHandler: (void (^)(id<AFMultipartFormData> formData))dataHandler withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    [self
     POST:urlString
     parameters:postData
     constructingBodyWithBlock:dataHandler
     success:^(NSURLSessionDataTask *task, id responseObject) {
         successHandler(responseObject);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [self handleFailure:error withResponse:task.response withFailureHandler:failureHandler];
     }];
}

-(void)uploadTo:(NSString *)urlString withData:(NSDictionary *)postData withFileInfo:(NSDictionary *)fileData withSuccessHandler:(void (^) (id responseObject))successHandler withProgressHandler:(void(^) (NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    // Create a multipart form request.
    NSMutableURLRequest *multipartRequest = [[AFHTTPRequestSerializer serializer]
                                             multipartFormRequestWithMethod:@"POST"
                                             URLString:[NSString stringWithFormat:@"%@/%@", rootURL, urlString]
                                             parameters:postData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                 [formData appendPartWithFileData:[fileData objectForKey:@"fileData"] name:[fileData objectForKey:@"dataKey"] fileName:[fileData objectForKey:@"fileName"] mimeType:[fileData objectForKey:@"mimeType"]];
                                             } error:nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:multipartRequest
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                         successHandler(responseObject);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         failureHandler(error);
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation start];
    
}

-(void)uploadTo:(NSString *)urlString withData:(NSDictionary *)postData withFileInfo:(NSDictionary *)fileData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    
    // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
    // bug in NSURLSessionTask.
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    
    
    // Create a multipart form request.
    NSMutableURLRequest *multipartRequest = [[AFHTTPRequestSerializer serializer]
                                             multipartFormRequestWithMethod:@"POST"
                                             URLString:[NSString stringWithFormat:@"%@/%@", rootURL, urlString]
                                             parameters:postData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                 [formData appendPartWithFileData:[fileData objectForKey:@"fileData"] name:[fileData objectForKey:@"dataKey"] fileName:[fileData objectForKey:@"fileName"] mimeType:[fileData objectForKey:@"mimeType"]];
                                             } error:nil];
    
//     Dump multipart request into the temporary file.
        [self.requestSerializer
         requestWithMultipartFormRequest:multipartRequest
         writingStreamContentsToFile:tmpFileUrl
         completionHandler:^(NSError *error) {
             // Once the multipart form is serialized into a temporary file, we can initialize
             // the actual HTTP request using session manager.
    
             // Create default session manager.
             AFURLSessionManager *manager = self;
    
    
             // Show progress.
             NSProgress *progress = nil;
             // Here note that we are submitting the initial multipart request. We are, however,
             // forcing the body stream to be read from the temporary file.
    
             NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:multipartRequest
                                                                        fromFile:tmpFileUrl
                                                                        progress:&progress
                                                               completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                                   {
                                                       // Cleanup: remove temporary file.
                                                       [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                       // Do something with the result.
                                                       if (error) {
                                                          if(failureHandler)
                                                              failureHandler(error);
                                                       } else {
                                                           if(successHandler)
                                                               successHandler(responseObject);
                                                       }
                                                   }];
             // Start the file upload.
             [uploadTask resume];
         }];
    
}

- (void)putTo:(NSString *)urlString withData:(NSDictionary *)postData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    [self PUT:urlString parameters:postData success:^(NSURLSessionDataTask *task, id responseObject) {
        successHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleFailure:error withResponse:task.response withFailureHandler:failureHandler];
    }];
}

- (void)delete:(NSString *)urlString withData:(NSDictionary *)queryData withSuccessHandler:(void (^) (id responseObject))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler
{
    [self DELETE:urlString parameters:queryData success:^(NSURLSessionDataTask *task, id responseObject) {
        successHandler(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleFailure:error withResponse:task.response withFailureHandler:failureHandler];
    }];
}

-(void)handleFailure:(NSError *)error withResponse:(NSURLResponse *)response withFailureHandler:(void (^) (NSError *err))failureHandler
{
    if(failureHandler != nil) {
//        NSString *errorString = [[error.userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
//        NSLog(@"%@, code:%d", error.userInfo, error.code);
        if (error.code == -1009) {
            [SVProgressHUD dismiss];
            [SharedAppDelegate showLogin];
            
            // Should show alert after call "showLogin" function.
            [Utilities showMsg:@"Please check your internet connection!"];
        } else if (error.code == 401) {
            [self callLoginApi];
        } else {
//            [Utilities showMsg:@"You are forced to login again because of server error."];
            [self callLoginApi];
            
            [SVProgressHUD dismiss];
//            [SharedAppDelegate showLogin];
            
//            [Utilities showMsg:@"Server error occured. Please try again."];
            failureHandler(error);
        }
    }
}

- (void)callLoginApi {
    [SVProgressHUD dismiss];
    
    if([GlobalVars sharedInstance].isLoggedIn &&
       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"] &&
       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]) {
        
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
        
        
        [[APIController sharedInstance] loginWithEmail:username andPassword:password withSuccessHandler:^(id jsonData){
            
            if(jsonData[@"data"]) {
                NSLog(@"Status OK");
            } else {
                [SharedAppDelegate showLogin];
            }
        } withFailureHandler:^(NSError *error){
            
            [SharedAppDelegate showLogin];
        }];

    } else {
        [SharedAppDelegate showLogin];
    }
}

+ (void)showAlertFailure:(NSError *)err
{
    [self showAlertFailure:err withTitle:@"Request Error"];
}

+ (void)showAlertFailure:(NSError *)err fromResponse:(NSURLResponse *)response withTitle:(NSString *)title
{
    // Don't remember what I was going to do with this.
}

+ (void)showAlertFailure:(NSError *)err withTitle:(NSString *)title
{
    if (err && ([err.userInfo count] > 0) && ([err.userInfo objectForKey:@"JSONResponseSerializerWithDataKey"])) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:[[err.userInfo objectForKey:@"JSONResponseSerializerWithDataKey"] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

@end