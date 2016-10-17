//
//  IssuesVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "LeftPanelVC.h"

@interface IssuesVC : UIViewController <UITableViewDataSource, UITableViewDelegate> {

}

@property (nonatomic, strong) NSString *filterString;
@property (nonatomic, strong) NSMutableArray *issueArray;

@end
