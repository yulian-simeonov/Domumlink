//
//  LocationCell.h
//  DomumLink
//
//  Created by iOS Dev on 8/6/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UILabel *floornameLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIView *nolocationView;

- (void)proceedContents:(NSDictionary *)issueDict;

@end
