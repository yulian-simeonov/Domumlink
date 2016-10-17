//
//  MessageCell.h
//  DomumLink
//
//  Created by iOS Dev on 8/6/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statustatusLabelHeiConstraint;

- (void)proceedContents:(NSDictionary *)messageDict;

@end
