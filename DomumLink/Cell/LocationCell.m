//
//  LocationCell.m
//  DomumLink
//
//  Created by iOS Dev on 8/6/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)proceedContents:(NSDictionary *)issueDict {
    if(issueDict) {
        if([Utilities isValidString:issueDict[@"LocationInfo"][@"BuildingId"]]) {
            self.locationImage.hidden = NO;
            self.nolocationView.hidden = YES;
            NSString *buildingNameStr = GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"BuildingName"], @"");
            NSString *buildingAddrStr = [NSString stringWithFormat:@"%@, %@", GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"AddressLine1"], @""), GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"City"], @"")];
            
            self.buildingnameLabel.text = buildingNameStr;
            self.addressLabel.text = buildingAddrStr;
            
            if (issueDict[@"LocationInfo"][@"BuildingImageUrl"] && ![issueDict[@"LocationInfo"][@"BuildingImageUrl"] isKindOfClass:[NSNull class]]) {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self.locationImage sd_setImageWithURL:[NSURL URLWithString:GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"BuildingImageUrl"], @"")] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
                }];
            } else {
                self.locationImage.image = [UIImage imageNamed:@"img_nobuilding"];
            }
            
        } else {
            self.locationImage.hidden = YES;
            self.nolocationView.hidden = NO;
            self.buildingnameLabel.text = @"";
            self.addressLabel.text = @"";
            self.floornameLabel.text = @"";
            self.locationImage.image = [UIImage imageNamed:@"img_nobuilding"];
        }
        
        if ([Utilities isValidString:issueDict[@"LocationInfo"][@"ApartmentName"]]) {
            self.floornameLabel.text = [NSString stringWithFormat:@"%@. %@",
                                        LocalizedString(@"Apt"), GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"ApartmentName"], @"")];
        }
        
        if ([Utilities isValidString:issueDict[@"LocationInfo"][@"FloorName"]]) {
            self.floornameLabel.text = [NSString stringWithFormat:@"%@ Floor - %@", self.floornameLabel.text, GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"FloorName"], @"")];
        }
    }
}

@end
