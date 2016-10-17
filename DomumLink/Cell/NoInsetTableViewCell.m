//
//  CommonTableViewCell.m
//  Budget Life
//
//  Created by Yulian Simeonov on 2/5/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "NoInsetTableViewCell.h"

@implementation NoInsetTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
