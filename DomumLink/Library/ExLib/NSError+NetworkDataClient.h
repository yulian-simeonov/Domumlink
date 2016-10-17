//
//  NSError+NetworkDataClient_NSError.h
//  Rollette
//
//  Created by Emagid Corp on 5/20/14.
//  Copyright (c) 2014 Voated LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (NetworkDataClient)
- (void) showStatusMessage:(NSString *)title andCancelButtonTitle:(NSString *)cancelButtonTitle;
- (NSString *)statusMessage;
@end
