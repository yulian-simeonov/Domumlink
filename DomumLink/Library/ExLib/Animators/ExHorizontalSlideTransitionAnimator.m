//
//  TLTransitionAnimator.m
//  Rollette
//
//  Created by Emagid Corp on 2/28/14.
//  Copyright (c) 2014 Voated LLC. All rights reserved.
//

#import "ExHorizontalSlideTransitionAnimator.h"

@implementation ExHorizontalSlideTransitionAnimator
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Set our ending frame. We'll modify this later if we have to
    CGRect outgoingEndFrame = CGRectMake(-toViewController.view.bounds.size.width, 0, toViewController.view.bounds.size.width, toViewController.view.bounds.size.height);
    CGRect incomingEndFrame = CGRectMake(0, 0, toViewController.view.bounds.size.width, toViewController.view.bounds.size.height);
    
    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect incomingStartFrame = incomingEndFrame;
        incomingStartFrame.origin.x += incomingEndFrame.size.width;
        toViewController.view.frame = incomingStartFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fromViewController.view.frame = outgoingEndFrame;
            toViewController.view.frame = incomingEndFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        CGRect incomingStartFrame = incomingEndFrame;
        incomingStartFrame.origin.x -= incomingEndFrame.size.width;
        toViewController.view.frame = incomingStartFrame;
        
        outgoingEndFrame.origin.x = -outgoingEndFrame.origin.x;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = outgoingEndFrame;
            toViewController.view.frame = incomingEndFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}
@end
