//
//  SelectTenantsCell.m
//  QuizApp
//
//  Created by Tope Abayomi on 13/03/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

#import "SelectTenantsCell.h"

@implementation SelectTenantsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
