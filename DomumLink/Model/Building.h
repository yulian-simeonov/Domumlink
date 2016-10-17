//
//  Building.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/23/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Building : NSObject

@property (nonatomic, strong) NSString *buildingTitle;

@property (nonatomic, strong) NSString *buildingImageName;

@property (nonatomic, strong) NSString *buildingAddress;

@property (nonatomic, strong) NSMutableArray *floorArray;

@property (nonatomic) int Apartment;

@property (nonatomic) int Parking;

@property (nonatomic) int Storage;

@property (nonatomic) int NormalIssues;

@property (nonatomic) int SeriousIssues;

@property (nonatomic) int UrgentIssues;

@end
