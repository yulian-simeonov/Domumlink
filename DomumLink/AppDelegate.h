//
//  AppDelegate.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/12/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)sharedDelegate;

- (void)showLogin;
- (void)showSidePanel;

@end

