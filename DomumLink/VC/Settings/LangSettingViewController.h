//
//  LangSettingViewController.h
//  DomumLink
//
//  Created by iOS Dev on 8/14/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersonalSettingsVC;

@interface LangSettingViewController : UIViewController

@property (nonatomic, strong) PersonalSettingsVC* delegate;
@property (nonatomic, strong) NSDictionary *settingDict;

@end
