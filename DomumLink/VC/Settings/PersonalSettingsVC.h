//
//  PersonalSettingsVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 3/19/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) ELangCode langCode;

@end
