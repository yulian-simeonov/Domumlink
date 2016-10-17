//
//  BuildingDetailsVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildingDetailsCell.h"

@interface BuildingDetailsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, BuildingDetailsDelegate>

@property (nonatomic, strong) NSDictionary *buildingDict;

@end
