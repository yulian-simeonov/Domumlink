//
//  DomumLinkUser.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/14/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "DomumLinkUser.h"

@implementation DomumLinkUser

-(id)initWithDictionary:(NSDictionary*)dictionary{
    
    self = [super init];
    if(self){
        NSDictionary *userDict = dictionary[@"CurrentUser"];
        self.userId = GET_VALIDATED_STRING(userDict[@"UserId"], @"-1");
        self.alias = GET_VALIDATED_STRING(userDict[@"Alias"], @"");
        self.firstName = GET_VALIDATED_STRING(userDict[@"FirstName"], @"");
        self.lastName = GET_VALIDATED_STRING(userDict[@"LastName"], @"");
        self.email = GET_VALIDATED_STRING(userDict[@"Email"], @"");
        self.mobileNumber = GET_VALIDATED_STRING(userDict[@"MobileNumber"], @"");
        self.lastRecordingUrl = GET_VALIDATED_STRING(userDict[@"LastRecordingUrl"], @"");
        self.countryName = GET_VALIDATED_STRING(userDict[@"CountryName"], @"");
        self.password = GET_VALIDATED_STRING(userDict[@"Password"], @"");
        self.oneTimeLoginCode = GET_VALIDATED_STRING(userDict[@"OneTimeLoginCode"], @"");
        self.comments = GET_VALIDATED_STRING(userDict[@"Comments"], @"");
        self.typeName = GET_VALIDATED_STRING(userDict[@"TypeName"], @"");
        self.jobTitle = [Utilities isValidString:userDict[@"JobTitle"]] ? userDict[@"JobTitle"] : @"";
        
        // Available for employee user
        self.accountType = [userDict[@"AccountType"] integerValue];
        
        self.password = GET_VALIDATED_STRING(userDict[@"UserPassword"], @"");
        
        self.language = [userDict[@"Language"] intValue];
        self.countryId = [userDict[@"CountryId"] intValue];
        self.isActive = [userDict[@"IsActive"] boolValue];
        self.isDeleted = [userDict[@"IsDeleted"] boolValue];
        self.isInvitationSend = [userDict[@"IsInvitationSend"] boolValue];
        self.notifyFrom = [userDict[@"NotifyFrom"] intValue];
        self.notifyTo = [userDict[@"NotifyTo"] intValue];
        self.isAcceptTermsOfService = [userDict[@"IsAcceptTermsOfService"] boolValue];
        NSLog(@"%@", userDict);
        self.type = [userDict[@"Type"] intValue];
        self.contact24Hours = [userDict[@"Contact24Hours"] boolValue];
        self.isDelinquent = [userDict[@"IsDelinquent"] boolValue];
        self.ignoreClosedOrResolvedIssues = [userDict[@"IgnoreClosedOrResolvedIssues"] boolValue];
        
        if (self.type == EUserTypeEmployee) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSArray *permissions = dictionary[@"ManagerPermissions"];
            for (NSString *permission in permissions) {
                [dict setObject:@1 forKey:permission];
            }
            self.permissionDict = [NSDictionary dictionaryWithDictionary:dict];
        }
        
//        self.notificationLevel_InvolvedIn = [dictionary[@"NotificationLevel_InvolvedIn"] intValue];
//        self.notificationLevel_AllOther = [dictionary[@"NotificationLevel_AllOther"] intValue];
//        self.hideAdminProfileFromNonAdmins = [dictionary[@"HideAdminProfileFromNonAdmins"] boolValue];
        
        self.notificationOptions = userDict[@"NotificationOptions"];
        self.lockInfo = userDict[@"LockInfo"];
    }
    return self;
}


@end
