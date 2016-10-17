//
//  EmergencyContactCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/19/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmergencyContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeiConstraint;

@end
