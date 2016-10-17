//
//  MessageCell.m
//  DomumLink
//
//  Created by iOS Dev on 8/6/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)proceedContents:(NSDictionary *)messageDict {
    UILabel *messageLabel = (UILabel *)[self viewWithTag:1];
    UIView *messageView = (UIView *)[self viewWithTag:4];
    UILabel *posterLabel = (UILabel *)[self viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[self viewWithTag:3];
    UILabel *substatusLabel = (UILabel *)[self viewWithTag:5];
    
    // Visible for Tenants
    UIImageView *imageVisible = (UIImageView *)[self viewWithTag:10];
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant)
        imageVisible.hidden = YES;
    else
        imageVisible.hidden = ![messageDict[@"VisibleForTenants"] boolValue];
    
    
    // Posted Date Label
    NSDecimalNumber *submittedDate = messageDict[@"DateSubmitted"];
    submittedDate = submittedDate == (id)[NSNull null] ? [[NSDecimalNumber alloc] initWithBool: 0] : submittedDate;
    NSDateFormatter *dateFormatter = [GlobalVars sharedInstance].dateFormatterTime;
    
    if ([GlobalVars sharedInstance].langCode == ELangEnglish)
        [dateFormatter setDateFormat:@"MMM dd h:mm a"];
    else
        [dateFormatter setDateFormat:@"dd MMM H:mm"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [submittedDate doubleValue]];
    
    
    // Poster Label
    NSString *poster = @"";
    NSDictionary *creator = messageDict[@"Creator"];
    if ([[GlobalVars sharedInstance].currentUser.userId integerValue] == [creator[@"UserId"] integerValue]) {
        poster = LocalizedString(@"Me");
    } else {
        poster = [NSString stringWithFormat:@"%@", creator[@"UserName"]];
    }
    
    
    // Message Type and Text
    EMessageType messageType = [messageDict[@"MessageEventType"] integerValue];
    
    if (messageType == EMessageTypeStatusChange) {
        [messageView setBackgroundColor:[UIColor colorWithRed:206/255.0f green:92/255.0f blue:92/255.0f alpha:1.f]];
        [messageLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [messageLabel setTextColor:[UIColor blackColor]];
        
        if (messageType == EMessageTypePostMessage) {
            if ([[GlobalVars sharedInstance].currentUser.userId integerValue] == [creator[@"UserId"] integerValue]) {
                [messageView setBackgroundColor:[UIColor colorWithRed:241/255.0f green:254/255.0f blue:226/255.0f alpha:1.f]];
            } else if ([creator[@"UserType"] integerValue] == EUserTypeTenant) {
                [messageView setBackgroundColor:[UIColor colorWithRed:208/255.0f green:232/255.0f blue:242/255.0f alpha:1.f]];
            } else {
                [messageView setBackgroundColor:[UIColor colorWithRed:255/255.0f green:238/255.0f blue:228/255.0f alpha:1.f]];
            }
        }
    }
    
    
    posterLabel.text = poster;
    dateLabel.text = LocalizedDateString([dateFormatter stringFromDate: date]);
    if ([Utilities isValidString:messageDict[@"StatusName"]]) {
        substatusLabel.hidden = NO;
        _statustatusLabelHeiConstraint.constant = 23;
        [messageLabel setText:[NSString stringWithFormat:@"%@ - %@", messageDict[@"Text"], messageDict[@"StatusName"]]];
        substatusLabel.text = messageDict[@"SubStatusName"];
    }
    else {
        substatusLabel.hidden = YES;
        _statustatusLabelHeiConstraint.constant = 0;
        [messageLabel setText:messageDict[@"Text"]];
    }
}
@end
