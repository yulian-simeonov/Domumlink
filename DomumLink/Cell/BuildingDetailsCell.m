//
//  BuildingDetailsCell.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "BuildingDetailsCell.h"
#import "BuildingDetailsRoomCell.h"

@implementation BuildingDetailsCell

- (void)awakeFromNib {
    // Initialization code
    
    [_unitCollectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.unitArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BuildingDetailsRoomCell *cell = (BuildingDetailsRoomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"buildingDetailsRoomCell" forIndexPath:indexPath];
    
    NSDictionary *unitDict = _unitArray[indexPath.row];
    
    [self updateCellWithUnitStatus:unitDict cell:cell];
    
    return cell;
}

- (void)updateCellWithUnitStatus:(NSDictionary *)dict cell:(BuildingDetailsRoomCell *)cell {
    if (dict[@"CurrentLease"] && ![dict[@"CurrentLease"] isKindOfClass:[NSNull class]]) {
        cell.backgroundColor = UNITSTATUS_OCCUPIED_COLOR;
    } else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    if (dict[@"Unit"]) {
        [self updateUnitStatus:dict[@"Unit"][@"RenovationStatus"] cell:cell];
        cell.numberLabel.text = dict[@"Unit"][@"UnitName"];
    }
}

- (void)updateUnitStatus:(NSString *)statusCode cell:(BuildingDetailsRoomCell *)cell {
    if ([statusCode isKindOfClass:[NSDictionary class]])                // For avoiding crashes between live server and test server
        statusCode = [(NSDictionary *)statusCode objectForKey:@"Name"];
    statusCode = [statusCode stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([statusCode isEqualToString:@"Ready"]) {
        cell.statusView.backgroundColor = [UIColor clearColor];
    } else if ([statusCode isEqualToString:@"ToBeAssessed"]) {
        cell.statusView.backgroundColor = UNITSTATUS_TOBEASSESSED_COLOR;
    } else if ([statusCode isEqualToString:@"ToBeRepaired"]) {
        cell.statusView.backgroundColor = UNITSTATUS_TOBEREPAIRED_COLOR;
    } else if ([statusCode isEqualToString:@"UnderRepairing"]) {
        cell.statusView.backgroundColor = UNITSTATUS_UNDERREPAIR_COLOR;
    } else if ([statusCode isEqualToString:@"UpcommingVacancy"]) {
        cell.statusView.backgroundColor = UNITSTATUS_UPCOMINGVACANCY_COLOR;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.unitCollectionView.frame.size.width - 20) / 4 - 5;
    CGFloat height = 40;
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *unitDict = _unitArray[indexPath.row];
    [_roomInfoDelegate onRoomClicked:unitDict[@"Unit"][@"UnitId"]];
}

@end
