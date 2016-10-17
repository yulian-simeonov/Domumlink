//
//  Utilities.h
//  Tappin
//
//  Created by Yulian SimeonovBogdan on 5/11/13.
//  Copyright (c) 2013 Yulian SimeonovBogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (BOOL) isValidString:(NSString*) str;
+ (BOOL) validateEmailWithString:(NSString*)email;
+ (void) showMsg:(NSString*)strMsg;

+ (NSString*)filteredDigitsOfPhoneNumber:(NSString*)string;
+ (NSString *)convertFormatedPhoneNumberToSimpleNumber:(NSString*)string;
+ (NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar;
+ (NSString *)formatStringWithSpace:(NSString *)str;
+ (UIColor*)colorWithHexString:(NSString*)hex;

+ (UIImage *)imageToUploadFromImage:(UIImage *)image;

/**
 *  Update UI with the changed language
 */
+ (void)applyLanguageChange;
@end
