//
//  DomumLinkUser.h
//  DomumLink
//
//  Created by Yulian Simeonov on 4/14/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Macro.h"

@interface DomumLinkUser : NSObject

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *alias;

@property (nonatomic, strong) NSString *firstName;

@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *mobileNumber;

@property (nonatomic, strong) NSString *lastRecordingUrl;

@property (nonatomic) int language;

@property (nonatomic) int countryId;

@property (nonatomic, strong) NSString *countryName;

@property (nonatomic, strong) NSDictionary *notificationOptions;

@property (nonatomic) bool isActive;

@property (nonatomic) bool isDeleted;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *oneTimeLoginCode;

@property (nonatomic) bool isInvitationSend;

@property (nonatomic, strong) NSString *comments;

@property (nonatomic) int notifyFrom;

@property (nonatomic) int notifyTo;

@property (nonatomic) bool isAcceptTermsOfService;

@property (nonatomic) EUserType type;

@property (nonatomic, strong) NSString *typeName;

@property (nonatomic, strong) NSString *jobTitle;

@property (nonatomic) bool contact24Hours;

@property (nonatomic, strong) NSDictionary *lockInfo;

@property (nonatomic) bool isDelinquent;

@property (nonatomic) bool ignoreClosedOrResolvedIssues;

@property (nonatomic) int notificationLevel_InvolvedIn;

@property (nonatomic) int notificationLevel_AllOther;

@property (nonatomic) bool hideAdminProfileFromNonAdmins;

@property (nonatomic) NSInteger accountType;

@property (nonatomic, strong) NSDictionary *permissionDict;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
