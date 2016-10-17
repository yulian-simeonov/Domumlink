//
//  AppDelegate.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/12/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "AppDelegate.h"

#import <Appsee/Appsee.h>
#import "LoginVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Appsee start:@"49b7310d45fd458ba5bff627ba3853d7"];
    
    NSString *lang = [GlobalVars sharedInstance].langCode == ELangEnglish ? @"en" : @"fr";

    LocalizationSetLanguage(lang);
    
    return YES;
}

+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[APIController sharedInstance] callLoginApi];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showLogin {
    [[GlobalVars sharedInstance] setIsLoggedIn:NO];
    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[LoginVC class]]) {
        UIViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginVC"];
        [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
    }
}

- (void)showSidePanel {
    UIViewController *sideVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"sidePanel"];
    [UIApplication sharedApplication].keyWindow.rootViewController = sideVC;
}

@end
