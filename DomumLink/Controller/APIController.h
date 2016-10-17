//
//  APIController.h
//  DomumLink
//
//  Created by Mac on 5/2/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkDataClient.h"

@interface APIController : NetworkDataClient

+ (APIController *)sharedInstance;

// Authentification
- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password withSuccessHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// BuildingStatus
- (void)feedBuildingsStatusWithSuccessHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// Buildin Info
- (void)feedBuildingInfoWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;
- (void)getBuildingDetailsWithBuildingId:(NSString *)buildingId withSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// Building Units
- (void)getBuildingUnitsWithUnitType:(NSString *)unitType andBuildingId:(NSString *)buildingId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;
- (void)getBuildingUnitsDetailWithUnitId:(NSInteger)unitId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// Tenants
- (void)feedTenantsWithBuildingId:(NSString *)buildingId PageNumber:(NSInteger)pageNum successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;
- (void)getTenantDetailWithTenantId:(NSInteger)tenantId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;
- (void)getPossibleAssigneesWithRecipientType:(NSInteger)recipientType buildingId:(NSString *)buildingId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// Update Issue Details
- (void)updateTenantWithIssueId:(NSInteger)issueId tenants:(NSArray *)tenants successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

- (void)updateAssigneeWithIssueId:(NSInteger)issueId assignees:(NSArray *)assignees successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

- (void)updateNotifyMeOptionWithIssueId:(NSInteger)issueId Email:(BOOL)notifyEmail Sms:(BOOL)notifySms Voice:(BOOL)notifyVoice SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// Possible Tennants
- (void)getPossibleTenantsWithRecipientType:(NSInteger)recipientType buildingId:(NSString *)buildingId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;

// Issues
- (void)feedIssuesWithPageId:(NSInteger)pageId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;
- (void)postIssueMessageWithIssueId:(NSString *)issueId andMessageStr:(NSString *)messageStr isVisibleForTenants:(BOOL)isVisibleForTenants successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)getIssueDetailWithIssueId:(NSInteger)issueId successHandler:(void (^) (id jsonData))successHandler withFailureHandler:(void (^) (NSError *err))failureHandler;
- (void)addIssueImageWithIssueId:(NSString *)issueId imageData:(NSData *)imageData progressHandler:(void(^) (NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressHandler successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// Change Status
- (void)getPossibleSubStatusesWithIssueId:(NSInteger)issueId targetStatus:(NSInteger)targetStatus successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)resolveStatusWithIssueId:(NSInteger)issueId targetStatus:(NSInteger)targetStatus force:(NSInteger)force targetSubStatus:(NSInteger)targetSubStatus reopenMsg:(NSString *)reopenMsg successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)changeStatusToCompleteWithIssueId:(NSInteger)issueId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)changeStatusToDelayWithIssueId:(NSInteger)issueId successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// Create Issue
- (void)getModelForNewIssueWithRecipientType:(NSInteger)recipientType successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)createNewIssue:(NSDictionary *)issueInfo successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)uploadTempImageWithImageData:(NSData *)imageData progressHandler:(void(^) (NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressHandler successHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler ;

- (void)getIssueCategoryWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)getIssueLocationTypeWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)getIssueLocationsWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)getIssueLocationBuildingsWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)getIssueLocationFloorsWithLocationId:(NSInteger)locationId LocationBuildingId:(NSInteger)locationBuildingId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

- (void)getIssueLocationApartmentsWithLocationBuildingId:(NSInteger)locationBuildingId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// Personal Settings
- (void)getPersonalSettingsWithSuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;
- (void)updatePersonalSettingsWithSettingData:(NSDictionary *)dictData SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

// GET Message, Issue ReadStatus
- (void)getIssueReadStatusWithIssueId:(NSString *)issueId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;
- (void)getMsgReadStatusWithMessageId:(NSString *)msgId SuccessHandler:(void (^) (id jsonData))successHandler failureHandler:(void (^) (NSError *err))failureHandler;

@end
