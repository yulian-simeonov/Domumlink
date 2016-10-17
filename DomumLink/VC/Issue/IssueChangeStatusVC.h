//
//  IssueChangeStatusVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 4/16/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueChangeStatusVC : UIViewController

@property (nonatomic) EIssueStatusType issueStatus;
@property (nonatomic, assign) BOOL isIssueCreator;

@end
