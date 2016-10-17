//
//  APIController.m
//  DomumLink
//
//  Created by Mac on 5/2/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "APIController.h"
#import "JSONResponseSerializerWithData.h"
#import <Appsee/Appsee.h>

@implementation APIController

+ (APIController *)sharedInstance
{
    static APIController *sharedInstance;
    
    if(sharedInstance == nil)
    {
        sharedInstance = [[APIController alloc] initWithBaseURL:API_DOMAIN];
        sharedInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
        sharedInstance.responseSerializer = [JSONResponseSerializerWithData serializerWithReadingOptions:NSJSONReadingMutableContainers];
    }
    
    return sharedInstance;
}

#pragma mark - Authentification

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password withSuccessHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_LOGIN_URL withData:@{@"userEmail":email, @"password":password} withSuccessHandler:^(id responseObject){
        if(responseObject[@"data"]){
            if(responseObject[@"data"][@"CurrentUser"]){
                [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"UserEmail"];
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"UserPassword"];
                
                [responseObject[@"data"][@"CurrentUser"] setObject:password forKey:@"UserPassword"];
                
                NSLog(@"%@", responseObject);
                
                [Appsee setUserID:responseObject[@"data"][@"CurrentUser"][@"Email"]];
                
                [GlobalVars sharedInstance].currentUser = [[DomumLinkUser alloc] initWithDictionary:responseObject[@"data"]];
                
                if(responseObject[@"data"][@"UnreadCount"])
                    [GlobalVars sharedInstance].unreadIssuesCount = [responseObject[@"data"][@"UnreadCount"] intValue];
                
                if(responseObject[@"data"][@"OpenCount"])
                    [GlobalVars sharedInstance].openIssuesCount = [responseObject[@"data"][@"OpenCount"] intValue];
                
                [[GlobalVars sharedInstance] setIsLoggedIn:YES];
                
                ELangCode langCode = [responseObject[@"data"][@"CurrentUser"][@"Language"] integerValue];
                if (langCode != [GlobalVars sharedInstance].langCode) {
                    [GlobalVars sharedInstance].langCode = langCode;
                    
                    [Utilities applyLanguageChange];
                }
            }
        }
        else if(responseObject[@"error"]){
            NSString *errorMsg = [NSString stringWithFormat:@"%@", responseObject[@"error"]];
            if([errorMsg isEqualToString:@"LoginOrPasswordIncorrect"]){
                ALERT(@"Error", @"Your email or password is not correct. Please try again.");
            }
        }
        else{
            ALERT(@"Error", @"An error occured whiled trying to login.");
        }
        
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Building Status

- (void)feedBuildingsStatusWithSuccessHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_GET_BUILDINGS_STATUS_URL withData:nil withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Building Info

- (void)feedBuildingInfoWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler{
    [self postTo:API_GET_BUILDINGS_INFO_URL withData:nil withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getBuildingDetailsWithBuildingId:(NSString *)buildingId withSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:[NSString stringWithFormat:API_GET_BUILDINGS_DETAILS_URL, buildingId] withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Tenants

- (void)feedTenantsWithBuildingId:(NSString *)buildingId PageNumber:(NSInteger)pageNum successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *url = API_GET_TENANTS_LIST_URL;
    NSMutableDictionary *dictParam = [NSMutableDictionary dictionary];
    if (buildingId)
        [dictParam setObject:buildingId forKey:@"BuildingId"];
//        url = [NSString stringWithFormat:@"%@?BuildingId=%@", url, buildingId];
    if (pageNum)
        [dictParam setObject:@(pageNum) forKey:@"page"];
//        url = [NSString stringWithFormat:@"%@page=%@", url, buildingId];
    [self postTo:url withData:dictParam withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getTenantDetailWithTenantId:(NSInteger)tenantId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_GET_TENANT_DETAIL_URL withData:@{@"id":@(tenantId)} withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getPossibleTenantsWithRecipientType:(NSInteger)recipientType buildingId:(NSString *)buildingId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *url = API_GET_POSSIBLE_TENANTS_LIST_URL;
    url = [NSString stringWithFormat:@"%@?RecipientType=%ld", url, (long)recipientType];
    if (buildingId)
        url = [NSString stringWithFormat:@"%@&LocationBuildingId=%@", url, buildingId];
    [self postTo:url withData:nil withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getPossibleAssigneesWithRecipientType:(NSInteger)recipientType buildingId:(NSString *)buildingId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *url = API_GET_POSSIBLE_ASSIGNEES_LIST_URL;
    url = [NSString stringWithFormat:@"%@?RecipientType=%ld", url, (long)recipientType];
    if (buildingId)
        url = [NSString stringWithFormat:@"%@&LocationBuildingId=%@", url, buildingId];
    [self postTo:url withData:nil withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Issues

- (void)feedIssuesWithPageId:(NSInteger)pageId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *urlStr = API_GET_ISSUE_LIST_URL;
    if (pageId) {
        urlStr = [NSString stringWithFormat:@"%@?page=%ld", API_GET_ISSUE_LIST_URL, (long)pageId];
    }
    [self postTo:urlStr withData:nil withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)postIssueMessageWithIssueId:(NSString *)issueId andMessageStr:(NSString *)messageStr isVisibleForTenants:(BOOL)isVisibleForTenants successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSString *visible = isVisibleForTenants ? @"true" : @"false";
    [self postTo:API_ISSUE_POST_MESSAGE_URL withData:@{@"issueId":issueId, @"message":messageStr, @"visibleForTenants":visible} withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getIssueDetailWithIssueId:(NSInteger)issueId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *urlStr = API_GET_ISSUE_DETAIL_URL;
    if (issueId) {
        urlStr = [NSString stringWithFormat:API_GET_ISSUE_DETAIL_URL, @(issueId)];
    }
    [self postTo:urlStr withData:nil withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)addIssueImageWithIssueId:(NSString *)issueId imageData:(NSData *)imageData progressHandler:(void(^) (NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressHandler successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSString *urlStr = API_ISSUE_POST_IMAGE_URL;
    if (issueId) {
        urlStr = [NSString stringWithFormat:@"%@?issueId=%@", API_ISSUE_POST_IMAGE_URL, issueId];
    }
    
    NSDictionary *imageUploadData = @{@"fileData": imageData, @"dataKey":@"files", @"fileName": [NSString stringWithFormat:@"%f.jpg", [NSDate timeIntervalSinceReferenceDate]], @"mimeType":@"image/jpeg"};
    
    [self uploadTo:urlStr withData:nil withFileInfo:imageUploadData withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withProgressHandler:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    } withFailureHandler:^(NSError *err) {
        failureHandler(err);
    }];
    
//    [self uploadTo:urlStr withData:nil withFileInfo:imageUploadData withSuccessHandler:^(id jsonData) {
//        successHandler(jsonData);
//    } withFailureHandler:^(NSError *error) {
//        failureHandler(error);
//    }];
    
//    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_DOMAIN, API_ISSUE_POST_IMAGE_URL];
//    if (issueId) {
//        urlStr = [NSString stringWithFormat:@"%@?issueId=%@", urlStr, issueId];
//    }
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
//    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:imageData
//                                    name:@"files"
//                                fileName:[NSString stringWithFormat:@"%f.jpg", [NSDate timeIntervalSinceReferenceDate]] mimeType:@"image/jpeg"];
//        
//        // etc.
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Response: %@", responseObject);
//        successHandler(responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        failureHandler(error);
//    }];
}

#pragma mark - Building Units

- (void)getBuildingUnitsWithUnitType:(NSString *)unitType andBuildingId:(NSString *)buildingId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:[NSString stringWithFormat:API_GET_BUILDINGS_UNITS_URL, unitType, buildingId] withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getBuildingUnitsDetailWithUnitId:(NSInteger)unitId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_GET_BUILDINGS_UNIT_DETAIL_URL withData:@{@"unitID":@(unitId)} withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getBuildingsInfoWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_GET_BUILDINGS_INFO_URL withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Change Status
- (void)getPossibleSubStatusesWithIssueId:(NSInteger)issueId targetStatus:(NSInteger)targetStatus successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    NSDictionary *param = @{@"issueId" : @(issueId), @"targetStatus" : @(targetStatus)};
    
    [self postTo:API_GET_POSSIBLE_SUBSTATUSES_URL withData:param withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)resolveStatusWithIssueId:(NSInteger)issueId targetStatus:(NSInteger)targetStatus force:(NSInteger)force targetSubStatus:(NSInteger)targetSubStatus reopenMsg:(NSString *)reopenMsg successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    NSDictionary *param = @{@"issueId" : @(issueId), @"targetStatus" : @(targetStatus), @"Force" : @(force), @"TargetSubStatus" : @(targetSubStatus), @"ReopenMessage" : reopenMsg};
    
    [self postTo:API_GET_RESOLVE_STATUS_URL withData:param withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)changeStatusToCompleteWithIssueId:(NSInteger)issueId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    NSDictionary *param = @{@"issueId" : @(issueId), @"targetStatus" : @(1)};
    [self postTo:API_GET_POSSIBLE_SUBSTATUSES_URL withData:param withSuccessHandler:^(id responseObject) {
        NSDictionary *param1 = @{@"issueId" : @(issueId), @"targetStatus" : @(1), @"Force" : responseObject[@"Force"], @"TargetSubStatus" : @(17), @"ReopenMessage" : responseObject[@"ReopenMessage"]};
        
        [self postTo:API_GET_RESOLVE_STATUS_URL withData:param1 withSuccessHandler:^(id responseObject) {
            successHandler(responseObject);
        } withFailureHandler:^(NSError *error){
            failureHandler(error);
        }];
        
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)changeStatusToDelayWithIssueId:(NSInteger)issueId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    NSDictionary *param = @{@"issueId" : @(issueId), @"targetStatus" : @(0)};
    [self postTo:API_GET_POSSIBLE_SUBSTATUSES_URL withData:param withSuccessHandler:^(id responseObject) {
        NSDictionary *param1 = @{@"issueId" : @(issueId), @"targetStatus" : @(0), @"Force" : responseObject[@"Force"], @"TargetSubStatus" : @(5), @"ReopenMessage" : responseObject[@"ReopenMessage"]};
        
        [self postTo:API_GET_RESOLVE_STATUS_URL withData:param1 withSuccessHandler:^(id responseObject) {
            successHandler(responseObject);
        } withFailureHandler:^(NSError *error){
            failureHandler(error);
        }];
        
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - CreateIssue
- (void)getModelForNewIssueWithRecipientType:(NSInteger)recipientType successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSDictionary *param = @{@"recipientType" : @(recipientType)};
    
    [self postTo:API_GET_MODEL_NEWISSUE withData:param withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)createNewIssue:(NSDictionary *)issueInfo successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    [self postTo:API_CREATE_NEWISSUE withData:issueInfo withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)uploadTempImageWithImageData:(NSData *)imageData progressHandler:(void(^) (NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressHandler successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSString *urlStr = API_ISSUE_UPLOAD_TEMP_IMAGE;
    
    NSDictionary *imageUploadData = @{@"fileData": imageData, @"dataKey":@"files", @"fileName": [NSString stringWithFormat:@"%f.jpg", [NSDate timeIntervalSinceReferenceDate]], @"mimeType":@"image/jpeg"};
    
//    [self uploadTo:urlStr withData:nil withFileInfo:imageUploadData withSuccessHandler:^(id jsonData) {
//        successHandler(jsonData);
//    } withFailureHandler:^(NSError *error) {
//        failureHandler(error);
//    }];
    
    [self uploadTo:urlStr withData:nil withFileInfo:imageUploadData withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withProgressHandler:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    } withFailureHandler:^(NSError *err) {
        failureHandler(err);
    }];
    
//    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_DOMAIN, API_ISSUE_UPLOAD_TEMP_IMAGE];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
//    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:imageData
//                                    name:@"files"
//                                fileName:[NSString stringWithFormat:@"%f.jpg", [NSDate timeIntervalSinceReferenceDate]] mimeType:@"image/jpeg"];
//        
//        // etc.
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Response: %@", responseObject);
//        successHandler(responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        failureHandler(error);
//    }];
}

- (void)getIssueCategoryWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    [self postTo:API_GET_CATEGORIES withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getIssueLocationTypeWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    [self postTo:API_GET_LOCATION_TYPES withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getIssueLocationsWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    [self postTo:API_GET_LOCATIONS withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getIssueLocationBuildingsWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    [self postTo:API_GET_LOCATION_BUILDINGS withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getIssueLocationFloorsWithLocationId:(NSInteger)locationId LocationBuildingId:(NSInteger)locationBuildingId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSDictionary *param = @{@"locationId":@(locationId), @"locationBuildingId":@(locationBuildingId)};
    [self postTo:API_GET_LOCATION_FLOORS withData:param withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getIssueLocationApartmentsWithLocationBuildingId:(NSInteger)locationBuildingId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSDictionary *param = @{@"locationBuildingId":@(locationBuildingId)};
    [self postTo:API_GET_LOCATION_APARTMENTS withData:param withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Update Issue Detail API

- (void)updateTenantWithIssueId:(NSInteger)issueId tenants:(NSArray *)tenants successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *url = API_UPDATE_TENANTS_URL;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(issueId) forKey:@"issueId"];
    
    for (int i=0; i<tenants.count; i++) {
        NSDictionary *dict = tenants[i];
        NSString *keyStr = [NSString stringWithFormat:@"recipientIds[%d]", i];
        [param setObject:dict[@"UserId"] forKey:keyStr];
    }
    
    //    NSString *tenantsStr = [NSString stringWithFormat:@"[%@]", [userIds componentsJoinedByString:@","]];
    
    [self postTo:url withData:param withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)updateAssigneeWithIssueId:(NSInteger)issueId assignees:(NSArray *)assignees successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler {
    NSString *url = API_UPDATE_ASSIGNEES_URL;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(issueId) forKey:@"issueId"];
    
    for (int i=0; i<assignees.count; i++) {
        NSDictionary *dict = assignees[i];
        NSString *keyStr = [NSString stringWithFormat:@"assigneeIds[%d]", i];
        [param setObject:dict[@"UserId"] forKey:keyStr];
    }
    
    //    NSString *tenantsStr = [NSString stringWithFormat:@"[%@]", [userIds componentsJoinedByString:@","]];
    
    [self postTo:url withData:param withSuccessHandler:^(id responseObject){
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)updateNotifyMeOptionWithIssueId:(NSInteger)issueId Email:(BOOL)notifyEmail Sms:(BOOL)notifySms Voice:(BOOL)notifyVoice SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    NSString *email = notifyEmail ? @"true" : @"false";
    NSString *sms = notifySms ? @"true" : @"false";
    NSString *voice = notifyVoice ? @"true" : @"false";
    NSDictionary *param = @{@"issueId":@(issueId), @"notifyMe.Email":email, @"notifyMe.Sms":sms, @"notifyMe.Voice":voice};
    [self postTo:API_UPDATE_NOTIFYMEOPTIONS_URL withData:param withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Get Message Detail API
- (void)getIssueReadStatusWithIssueId:(NSString *)issueId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    NSString *strUrl = [NSString stringWithFormat:API_GET_ISSUE_READSTATUS, issueId];
    [self postTo:strUrl withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)getMsgReadStatusWithMessageId:(NSString *)msgId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    
    NSString *strUrl = [NSString stringWithFormat:API_GET_MSG_READSTATUS, msgId];
    [self postTo:strUrl withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

#pragma mark - Personal Setting API
- (void)getPersonalSettingsWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_GET_PERSONAL_SETTINGS withData:nil withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

- (void)updatePersonalSettingsWithSettingData:(NSDictionary *)dictData SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler {
    [self postTo:API_UPDATE_PERSONAL_SETTINGS withData:dictData withSuccessHandler:^(id responseObject) {
        successHandler(responseObject);
    } withFailureHandler:^(NSError *error){
        failureHandler(error);
    }];
}

@end
