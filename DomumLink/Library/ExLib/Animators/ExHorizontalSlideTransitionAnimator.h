//
//  TLTransitionAnimator.h
//  Rollette
//
//  Created by Emagid Corp on 2/28/14.
//  Copyright (c) 2014 Voated LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface ExHorizontalSlideTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@end
