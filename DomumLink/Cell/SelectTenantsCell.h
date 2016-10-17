//
//  SelectTenantsCell.h
//  QuizApp
//
//  Created by Tope Abayomi on 13/03/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableViewCell.h"

@interface SelectTenantsCell : SKSTableViewCell

@property (nonatomic, weak) IBOutlet UILabel* tenantNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView* selectionImageView;

@property (nonatomic, weak) IBOutlet UIView* signedupView;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@end
