//
//  BuildingStatusCell.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "BuildingStatusCell.h"

@implementation BuildingStatusCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)proceedContent:(NSDictionary *)unitData {
    // Localization
    _vacancyLabel.text = LocalizedString(@"Vacancy");
    _unresolvedlabel.text = LocalizedString(@"UnresolvedIssues");
    _apartDescLabel.text = LocalizedString(@"Apartment1");
    _parkingDescLabel.text = LocalizedString(@"Parking");
    _storageDescLabel.text = LocalizedString(@"Storage");
    _normalDescLabel.text = LocalizedString(@"Normal");
    _seriousDescLabel.text = LocalizedString(@"Serious");
    _urgentDescLabel.text = LocalizedString(@"Urgent");
}

@end
