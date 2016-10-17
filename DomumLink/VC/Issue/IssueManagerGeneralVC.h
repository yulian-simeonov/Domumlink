//
//  IssueManagerGeneralVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueManagerGeneralVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSDictionary *issueDictionary;
@property (nonatomic) NSInteger tableIndex;

- (void)closeTabScrollView;
- (void)updateContentWithIssueData:(NSDictionary *)issueDict;
- (void)updateContentUponStatusChange;

- (void)disableDelayButton;
- (void)enableChangeStatusButton;

@end
