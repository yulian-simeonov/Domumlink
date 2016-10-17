//
//  BuildingStatusCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingStatusCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *buildingImageView;

@property (nonatomic, strong) IBOutlet UILabel *buildingTitleLabel;

@property (nonatomic, strong) IBOutlet UILabel *apartmentLabel;

@property (nonatomic, strong) IBOutlet UILabel *parkingLabel;

@property (nonatomic, strong) IBOutlet UILabel *storageLabel;

@property (nonatomic, strong) IBOutlet UILabel *normalLabel;

@property (nonatomic, strong) IBOutlet UILabel *seriousLabel;

@property (nonatomic, strong) IBOutlet UILabel *urgentLabel;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *vacancyLabel;
@property (weak, nonatomic) IBOutlet UILabel *unresolvedlabel;

@property (weak, nonatomic) IBOutlet UILabel *apartDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *parkingDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *storageDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *normalDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *seriousDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *urgentDescLabel;

- (void)proceedContent:(NSDictionary *)unitData;

@end
