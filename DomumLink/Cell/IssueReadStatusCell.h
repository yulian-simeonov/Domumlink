//
//  IssueReadStatusCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 2/5/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueReadStatusCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *identityLabel;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *readStatusLabel;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
