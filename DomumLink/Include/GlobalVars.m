//
//  GlobalVars.m
//  DomumLink
//
//  Created by Yulian Simeonov on 3/19/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars

@synthesize authCookie = _authCookie;

@synthesize currentUser = _currentUser;

@synthesize changeStatusArray = _changeStatusArray;

@synthesize issueStatusArray = _issueStatusArray;

@synthesize tenantArray = _tenantArray;

@synthesize unreadIssuesCount = _unreadIssuesCount;

@synthesize openIssuesCount = _openIssuesCount;

@synthesize dateFormatterTime = _dateFormatterTime;

@synthesize isEasymode = _isEasymode;

@synthesize isLoggedIn = _isLoggedIn;

@synthesize langCode = _langCode;

+ (GlobalVars *)sharedInstance {
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _authCookie = [[NSHTTPCookie alloc] init];
        _currentUser = [[DomumLinkUser alloc] init];
        
        
        // Permission array
        _buildingstatusPermissions = @[@"CanViewTenantPhoneNumberEmailDOB", @"CanViewAllTenantsFromVisibleBuildings", @"CanAccessToTrendsAndReports"];
        _tenantsPermissions = @[@"CanViewTenantPhoneNumberEmailDOB", @"CanViewAllTenantsFromVisibleBuildings"];
        _sendIssueToTenantsPermissions = @[@"CanSendIssueToTenants"];
        _respondToTenantCreatedIssuePermissions = @[@"CanRespondToTenantCreatedIssues"];
        _respondToEmployeeCreatedIssuePermissions = @[@"CanRespondToEmployeeCreatedTenantIssues"];
        _canWriteMsgOnTenantIssuePermission = @[@"CanPostInternalMessages"];
        _canEditAssigneePerssion = @[@"CanAddAssignees", @"CanRemoveAssignees"];
        _canEditRecipientPerssion = @[@"CanAddRecipients", @"CanRemoveRecipients"];
        _canChangeStatusOfEmployeeCreatedIssuePermission = @[@"CanChangeEmployeeCreatedTenantIssuesStatus"];
        _canChangeStatusOfTenantCreatedIssuePermission = @[@"CanChangeTenantCreatedIssuesStatus"];
        _canForceResolveAndReOpenIssuePermission = @[@"CanForceResolveAndReOpenIssue"];
        _canViewEmployeeMobileNumberPermission = @[@"CanViewEmployeeMobileNumber"];
        _canViewTenantPhoneNumberEmailDOBPermission = @[@"CanViewTenantPhoneNumberEmailDOB"];
        _canViewTenantCommentPermission = @[@"CanViewTenantComment"];
        
        NSArray *reportProgressArray = @[@"Work in Progress", @"Need Additional Info", @"Not Started", @"Delayed", @"3rd Parties Contacted", @"Waiting for Repairs", @"Investigating", @"Working on a Solution"];
        NSArray *resolvedArray = @[@"No Solution Possible", @"Unfortunately we cannot help", @"Payment received", @"Repairs completed", @"Completed"];
        NSArray *cancelIssueArray = @[@"Problem solved itself", @"No longer an issue", @"Created by mistake"];
        
        _changeStatusArray = @[reportProgressArray, resolvedArray, cancelIssueArray];
        
        _tenantArray = [[NSArray alloc] init];
        
        _unreadIssuesCount = 0;
        _openIssuesCount = 0;
        
        
        _isEasymode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IsEasyMode"] boolValue];
        _isLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IsLoggedIn"] boolValue];
        _langCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LangCode"] integerValue];
        
        // Localization
        [self updateGlobalbarsWithLangCode];
    }
    return self;
}

- (void)updateGlobalbarsWithLangCode {
    _dateFormatterTime = [[NSDateFormatter alloc] init];
    if (self.langCode == ELangEnglish)
        [_dateFormatterTime setDateFormat:@"h:mm a"];
    else
        [_dateFormatterTime setDateFormat:@"H:mm"];
//    [_dateFormatterTime setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    
    NSArray *statuses = @[@"ReportProgress", @"Resolved", @"CancelIssue"];
    _issueStatusArray = LocalizedArray(statuses) ;
}

- (void)setIsEasymode:(BOOL)isEasymode {
    _isEasymode = isEasymode;
    [[NSUserDefaults standardUserDefaults] setObject:@(isEasymode) forKey:@"IsEasyMode"];
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn {
    _isLoggedIn = isLoggedIn;
    [[NSUserDefaults standardUserDefaults] setObject:@(isLoggedIn) forKey:@"IsLoggedIn"];
}

- (void)setLangCode:(ELangCode)langCode {
    _langCode = langCode;
    [[NSUserDefaults standardUserDefaults] setObject:@(langCode) forKey:@"LangCode"];
}

- (void)removeUserSetting {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserEmail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserPassword"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IsEasyMode"];
}

- (UIColor *)getStatusColorWithStatus:(NSInteger)statusCode SubStatusCode:(NSInteger)subStatusCode {
    // Update status color according sub status
    UIColor *statusColor = [Utilities colorWithHexString:@"CE5C5C"];
    if (statusCode == 0) { // Status: Open
        statusColor = [Utilities colorWithHexString:@"CE5C5C"];
    } else if (statusCode == 2) {
        statusColor = [Utilities colorWithHexString:@"27AEFA"];
    } else {
        if (subStatusCode == 13 || subStatusCode == 14)
            // NoSolutionPossible, UnfortunatelyWeCannotHelp
            statusColor = [Utilities colorWithHexString:@"FFA500"];
        else if (subStatusCode == 15 || subStatusCode == 16 || subStatusCode == 17)
            // PaymentReceived, RepairsCompleted, Complete
            statusColor = [Utilities colorWithHexString:@"7ED700"];
        else if (subStatusCode == 10)
            // ProblemSolvedItself
            statusColor = [Utilities colorWithHexString:@"27AEFA"];
    }
    return statusColor;
}

// Permissions

- (BOOL)hasBuildingStatusPermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.buildingstatusPermissions) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasTenantsPermission {
    
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.tenantsPermissions) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasSendIssueToTenantPermission {
    
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.sendIssueToTenantsPermissions) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasRespondToTenantCreatedIssuePermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.respondToTenantCreatedIssuePermissions) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasRespondToEmployeeCreatedIssuePermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.respondToEmployeeCreatedIssuePermissions) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

// Permission that can write message on Tenant issue
- (BOOL)hasWriteMsgOnTenantIssuePermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canWriteMsgOnTenantIssuePermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

// Permission that can edit assignee and tenant
- (BOOL)hasEditAssigneePermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canEditAssigneePerssion) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasEditRecipientPermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canEditRecipientPerssion) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

// Permission for change status of an employee created issue
- (BOOL)hasChangeStatusOfEmployeeCreatedIssue {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canChangeStatusOfEmployeeCreatedIssuePermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasChangeStatusOfTenantCreatedIssue {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canChangeStatusOfTenantCreatedIssuePermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasForceResolveAndReOpenIssue {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canForceResolveAndReOpenIssuePermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasViewEmployeeMobileNumberPermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canViewEmployeeMobileNumberPermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasViewTenantPhoneNumberEmailDOBPermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canViewEmployeeMobileNumberPermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasViewTenantCommentPermission {
    if (self.currentUser.type == EUserTypeEmployee) {
        for (NSString *permission in self.canViewTenantCommentPermission) {
            if (![self.currentUser.permissionDict objectForKey:permission]) {
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

@end