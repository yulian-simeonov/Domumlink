//
//  NSError+NetworkDataClient.m
//  Rollette
//
//  Created by Emagid Corp on 5/20/14.
//  Copyright (c) 2014 Voated LLC. All rights reserved.
//

#import "NSError+NetworkDataClient.h"

#import <UIKit/UIKit.h>

@implementation NSError (NetworkDataClient)
- (void) showStatusMessage:(NSString *)title andCancelButtonTitle:(NSString *)cancelButtonTitle
{
    NSString *message = [self statusMessage];
    UIAlertView *alertView = [[UIAlertView  alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    [alertView setMessage:message];
    [alertView show];
}

- (NSString *)statusMessage
{
    NSString *message = nil;
    NSDictionary *errorBodyResponse = [self.userInfo objectForKey:@"JSONResponseSerializerWithDataKey"];
    if(errorBodyResponse != nil)
    {
        message = [errorBodyResponse objectForKey:@"message"];
    }
    
    return message;
}
@end
