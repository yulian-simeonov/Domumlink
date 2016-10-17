//
//  BuildingScheduleCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/22/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingScheduleCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) IBOutlet UILabel *weekdayLabel;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@end
