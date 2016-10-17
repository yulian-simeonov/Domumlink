//
//  IssuesListCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssuesListCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) IBOutlet UILabel *createdForLabel;

@property (nonatomic, strong) IBOutlet UIImageView *priorityImageView;

@property (nonatomic, strong) IBOutlet UILabel *generatedByLabel;

@property (nonatomic, strong) IBOutlet UILabel *createdOnLabel;

@property (nonatomic, strong) IBOutlet UILabel *daysAgoLabel;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) IBOutlet UILabel *addressBigLabel;

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

@property (nonatomic, strong) IBOutlet UILabel *nameLocationLabel;

@property (nonatomic, strong) IBOutlet UIImageView *buildingImageView;

@property (nonatomic, strong) IBOutlet UIScrollView *buildingThumbnailsView;

@property (nonatomic, strong) IBOutlet UILabel *detailLabel;

@property (nonatomic, strong) IBOutlet UILabel *dueDateLabel;

@property (nonatomic, strong) IBOutlet UILabel *employeesLabel;

@property (nonatomic, strong) IBOutlet UILabel *tenantsLabel;

@property (nonatomic, strong) IBOutlet UILabel *messagesLabel;

@property (nonatomic, strong) IBOutlet UILabel *serialNoLabel;

@property (nonatomic, strong) IBOutlet UIView *fullAddressView;
@property (weak, nonatomic) IBOutlet UILabel *nolocationLabel;

@property (weak, nonatomic) IBOutlet UILabel *floorNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrlHeiConstraint;
@property (weak, nonatomic) IBOutlet UIView *scrolBelowLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterHeiConstraint;
@property (weak, nonatomic) IBOutlet UIView *counterView;

@property (weak, nonatomic) IBOutlet UIView *nolocationView;
@property (strong, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet UIView *statusBarView;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *nolocspecifiedLabel;

- (void)proceedContent:(NSDictionary *)issueDict section:(NSInteger)section viewMode:(NSInteger)viewMode;

@end
