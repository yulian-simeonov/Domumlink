//
//  BuildingDetailsCell.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BuildingDetailsDelegate <NSObject>

@optional
- (void) onRoomClicked:(NSString *)unitId;

@end

@interface BuildingDetailsCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) IBOutlet UILabel *floorNoLabel;

@property (nonatomic, retain) IBOutlet UIButton *helpButton;

@property (nonatomic, strong) NSMutableArray *unitArray;

@property (nonatomic, retain) IBOutlet UICollectionView *unitCollectionView;

@property (assign) id<BuildingDetailsDelegate> roomInfoDelegate;

@end
