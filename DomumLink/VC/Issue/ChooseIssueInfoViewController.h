//
//  ChooseIssueInfoViewController.h
//  DomumLink
//
//  Created by iOS Dev on 6/28/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseIssueInfoViewController : UIViewController

@property (nonatomic) NSInteger infoType;
@property (nonatomic) NSInteger locationId;
@property (nonatomic) NSInteger locationBuildingId;
@property (nonatomic) NSInteger selIndex;
@property (nonatomic) id delegate;

@end
