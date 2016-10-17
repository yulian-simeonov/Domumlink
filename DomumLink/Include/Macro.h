//
//  Config.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/15/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EUserTypeNone,
    EUserTypeEmployee,
    EUserTypeTenant
} EUserType;

typedef enum : NSUInteger {
    ERecipientTypeEmployee,
    ERecipientTypeTenant,
    ERecipientTypeServiceSupport,
    ERecipientTypeInternal
} ERecipientType;

typedef enum : NSUInteger {
    EMessageTypePostMessage,
    EMessageTypeStatusChange,
    EMessageTypeCategoryChange,
    EMessageTypePriorityChange
} EMessageType;

typedef enum : NSUInteger {
    EIssueStatusOpen,
    EIssueStatusResolved,
    EIssueStatusCanceled
} EIssueStatusType;

typedef enum : NSUInteger {
    ELocationNone,
    ELocationCommonArea,
    ELocationApartment
} ELocationType;

typedef enum : NSUInteger {
    ELangEnglish,
    ELangFrench
} ELangCode;

#define NSLog(...)

#define kPictureUploadLimit 5

#define kImageWidthToUpload 600

#define SCRN_WIDTH		[[UIScreen mainScreen] bounds].size.width
#define SCRN_HEIGHT		[[UIScreen mainScreen] bounds].size.height

//#define API_DOMAIN @"http://domumlinkcatest.cloudapp.net"
#define API_DOMAIN @"https://www.domumlink.ca"

#define API_LOGIN_URL @"Api/Login/SignIn"

#define API_GET_BUILDINGS_STATUS_URL @"Api/Buildings/BuildingStatus"

#define API_GET_BUILDINGS_INFO_URL @"Api/Buildings/BuildingInfo"

#define API_GET_BUILDINGS_DETAILS_URL @"Api/Buildings/Details/%@"

#define API_GET_BUILDINGS_UNITS_URL @"Api/Buildings/OccupancyStatus?unitType=%@&buildingId=%@"

#define API_GET_BUILDINGS_UNIT_DETAIL_URL @"Api/Buildings/UnitStatusDetails"

#define API_GET_TENANTS_LIST_URL @"Api/Tenants/List"

#define API_GET_POSSIBLE_TENANTS_LIST_URL @"api/issues/GetRecipients"

#define API_GET_POSSIBLE_ASSIGNEES_LIST_URL @"api/issues/GetAssignees"



#define API_GET_TENANT_DETAIL_URL @"Api/Tenants/Details"

#define API_GET_ISSUE_LIST_URL @"Api/Issues/OpenIssues"

#define API_GET_ISSUE_DETAIL_URL @"Api/Issues/Details?issueID=%@"

#define API_ISSUE_POST_MESSAGE_URL @"Api/Issues/PostMessage"

#define API_ISSUE_POST_IMAGE_URL @"Api/Issues/SaveIssueImage"

#define API_GET_POSSIBLE_SUBSTATUSES_URL @"Api/issues/resolutiondetails"

#define API_GET_RESOLVE_STATUS_URL @"Api/issues/ResolveOrClose"

// Update Issue Detail API
#define API_UPDATE_TENANTS_URL @"Api/issues/UpdateRecipients"
#define API_UPDATE_ASSIGNEES_URL @"Api/issues/UpdateAssignees"
#define API_UPDATE_NOTIFYMEOPTIONS_URL @"Api/Issues/UpdateNotifyMeOptions"

// Create Issue APIs
#define API_ISSUE_UPLOAD_TEMP_IMAGE @"Api/Issues/SaveTempImages"

#define API_GET_MODEL_NEWISSUE @"api/issues/new"
#define API_CREATE_NEWISSUE @"api/issues/create"
#define API_GET_CATEGORIES @"api/issues/GetCategories"
#define API_GET_LOCATION_TYPES @"api/issues/GetLocationTypes" 
#define API_GET_LOCATIONS @"api/issues/GetLocations"
#define API_GET_LOCATION_FLOORS @"api/issues/GetLocationFloors"
#define API_GET_LOCATION_BUILDINGS @"api/issues/GetLocationBuildings"
#define API_GET_LOCATION_APARTMENTS @"api/issues/GetLocationApartments"

// Personal Settings APIS
#define API_GET_PERSONAL_SETTINGS @"api/PersonalSettings"
#define API_UPDATE_PERSONAL_SETTINGS @"Api/PersonalSettings/Update"

// Get Msg, status detail API
#define API_GET_ISSUE_READSTATUS @"api/Issues/IssueReadStatus?issueId=%@"
#define API_GET_MSG_READSTATUS @"api/Issues/MessageReadStatus?messageId=%@"

// Notification key
//#define kNotiUpdatedMsg @"NotificationUpdatedMsg"
#define kNotiIssueUpdated @"NotificationIssueUpdate"
#define kNotiIssueCreate @"NotificationIssueCreate"
//#define kNotiIssueDetailUpdated @"NotificationIssueDetailUpdate"

#define kNotiIssueRefresh @"NotificationIssueRefresh"


#define SharedAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define ALERT(_title,_text)		[[[UIAlertView alloc] initWithTitle:_title message:_text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show]

#define GET_VALIDATED_STRING(_obj, _def_str) _obj == (id)[NSNull null] || _obj == nil ? _def_str : [NSString stringWithFormat:@"%@", _obj]

#define GET_VALIDATED_DOUBLE(_obj, _def_val) _obj == (id)[NSNull null] ? _def_val : [_obj doubleValue]

#define VALIDATE_STRING(_obj, _def_str) _obj = _obj == (id)[NSNull null] ? _def_str : [NSString stringWithFormat:@"%@", _obj];

#define NAV_BAR_COLOR RGB(90, 171, 227)

#define LIGHT_GRAY_COLOR RGB(221, 221, 221)

#define LIGHT_GRAY_COLOR1 RGB(204, 204, 204)

#define LIGHT_GRAY_COLOR2 RGB(225, 225, 225)

#define DARK_GRAY_COLOR1 RGB(67, 67, 67)

#define DARK_GRAY_COLOR RGB(102, 102, 102)

#define GRAY_COLOR RGB(153, 153, 153)

#define ORANGE_COLOR RGB(246, 178, 89)

#define GREEN_COLOR RGB(67, 191, 239)

#define UNIT_GREEN_COLOR RGB(152, 223, 51)

#define UNIT_BLUE_COLOR RGB(159, 216, 251)

#define BLUE_COLOR RGB(116, 182, 231)

#define UNIT_RED_COLOR RGB(215, 125, 125)

#define OPEN_STATUS_RED_COLOR RGB(206, 92, 92)

// Unit Status Color
#define UNITSTATUS_OCCUPIED_COLOR RGB(135, 206, 250)
#define UNITSTATUS_TOBEASSESSED_COLOR RGB(128, 0, 128)
#define UNITSTATUS_TOBEREPAIRED_COLOR RGB(255, 140, 0)
#define UNITSTATUS_UNDERREPAIR_COLOR RGB(205, 92, 92)
#define UNITSTATUS_UPCOMINGVACANCY_COLOR RGB(255, 212, 83)



#define FONTNAME_LIGHT @"OpenSans-Light"

#define FONTNAME_REGULAR @"OpenSans"

#define FONTNAME_SEMIBOLD @"OpenSans-Semibold"

#define FONTNAME_BOLD @"OpenSans-Bold"

#define AUTH_COOKIE_NAME @".ASPHAUTH"