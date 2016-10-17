//
//  UIImage+Util.h
//  SStylish
//
//  Created by Vlad Getman on 30.12.13.
//  Copyright (c) 2013 HalcyonLA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)mirrorCorrection;
- (UIImage *)fixOrientation;

@end
