//
//  BuildingDetailsRoomCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingDetailsRoomCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;

@end
