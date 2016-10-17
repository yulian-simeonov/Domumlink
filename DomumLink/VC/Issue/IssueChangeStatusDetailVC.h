//
//  IssueChangeStatusDetailVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueChangeStatusDetailVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) int changeStatusSelectedInd;
@property (nonatomic) NSInteger issueId;

@end
