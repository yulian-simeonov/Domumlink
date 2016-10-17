//
//  GlobalVars.h
//  DomumLink
//
//  Created by Yulian Simeonov on 3/19/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DomumLinkUser.h"
#import <UIKit/UIKit.h>

@class IssueManagerGeneralVC;

@interface GlobalVars : NSObject
{
    NSHTTPCookie *_authCookie;
    
    DomumLinkUser *_currentUser;
    
    NSArray *_changeStatusArray;
    
    NSArray *_issueStatusArray;
    
    NSArray *_tenantArray;
    
    int _unreadIssuesCount;
    
    int _openIssuesCount;
    
    NSDateFormatter *_dateFormatterTime;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSHTTPCookie *authCookie;

@property(strong, nonatomic, readwrite) DomumLinkUser *currentUser;

@property(strong, nonatomic, readonly) NSArray *issueStatusArray;

@property(strong, nonatomic, readonly) NSArray *changeStatusArray;

@property(strong, nonatomic, readwrite) NSArray *tenantArray;

@property(nonatomic, readwrite) int unreadIssuesCount;

@property(nonatomic, readwrite) int openIssuesCount;

@property(strong, nonatomic, readwrite) NSDateFormatter *dateFormatterTime;

@property (assign, nonatomic) BOOL isEasymode;
@property (assign, nonatomic) BOOL isLoggedIn;
@property (assign, nonatomic) ELangCode langCode; //0:en, 1:fr

@property (nonatomic) NSInteger onWorkIssueId;

@property (nonatomic, strong) NSMutableDictionary *toCreateIssue;

// IssueManagerGeneralVC controller
@property (nonatomic, strong) IssueManagerGeneralVC *issueManager;

// Permissions
@property (nonatomic, strong) NSArray *buildingstatusPermissions;
@property (nonatomic, strong) NSArray *tenantsPermissions;
@property (nonatomic, strong) NSArray *sendIssueToTenantsPermissions;
@property (nonatomic, strong) NSArray *respondToTenantCreatedIssuePermissions;
@property (nonatomic, strong) NSArray *respondToEmployeeCreatedIssuePermissions;
@property (nonatomic, strong) NSArray *canWriteMsgOnTenantIssuePermission;
@property (nonatomic, strong) NSArray *canEditAssigneePerssion;
@property (nonatomic, strong) NSArray *canEditRecipientPerssion;
@property (nonatomic, strong) NSArray *canChangeStatusOfEmployeeCreatedIssuePermission;
@property (nonatomic, strong) NSArray *canChangeStatusOfTenantCreatedIssuePermission;
@property (nonatomic, strong) NSArray *canForceResolveAndReOpenIssuePermission;
@property (nonatomic, strong) NSArray *canViewEmployeeMobileNumberPermission;
@property (nonatomic, strong) NSArray *canViewTenantPhoneNumberEmailDOBPermission;
@property (nonatomic, strong) NSArray *canViewTenantCommentPermission;

- (void)removeUserSetting;

// Get Status Color
- (UIColor *)getStatusColorWithStatus:(NSInteger)statusCode SubStatusCode:(NSInteger)subStatusCode;

// Get Permission 
- (BOOL)hasBuildingStatusPermission;
- (BOOL)hasTenantsPermission;
- (BOOL)hasSendIssueToTenantPermission;
- (BOOL)hasRespondToTenantCreatedIssuePermission;
- (BOOL)hasRespondToEmployeeCreatedIssuePermission;
- (BOOL)hasWriteMsgOnTenantIssuePermission;
- (BOOL)hasEditAssigneePermission;
- (BOOL)hasEditRecipientPermission;
- (BOOL)hasChangeStatusOfEmployeeCreatedIssue;
- (BOOL)hasChangeStatusOfTenantCreatedIssue;
- (BOOL)hasForceResolveAndReOpenIssue;
- (BOOL)hasViewEmployeeMobileNumberPermission;
- (BOOL)hasViewTenantPhoneNumberEmailDOBPermission;
- (BOOL)hasViewTenantCommentPermission;

// Localization
- (void)updateGlobalbarsWithLangCode;

@end