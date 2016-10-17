//
//  IssueMsgDetailViewController.h
//  DomumLink
//
//  Created by Yosemite on 11/12/15.
//  Copyright © 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueMsgDetailViewController : UIViewController

@property (strong, nonatomic) NSString *issueId;
@property (strong, nonatomic) NSDictionary *issueMessageDict;
@property (strong, nonatomic) NSString *issueDescription;
@property (strong, nonatomic) NSString *issueCreator;
@property (assign, nonatomic) EUserType issueCreatorType;
@property (assign, nonatomic) BOOL isTenantIssue;
@property (strong, nonatomic) id issueCreatedDate;

@end
