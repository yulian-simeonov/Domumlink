//
//  Utilities.m
//  Tappin
//
//  Created by Yulian SimeonovBogdan on 5/11/13.
//  Copyright (c) 2013 Yulian SimeonovBogdan. All rights reserved.
//

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "Macro.h"
#import "UIImage+Util.h"

#define kPaddingBtnTitle    10

@implementation Utilities

#pragma mark Shadow Rendering

+ (BOOL) isValidString:(NSString*) str {
    
    NSString *check = [NSString stringWithFormat:@"%@", str];
    if (!str || [str isKindOfClass:[NSNull class]] || [check isEqualToString:@""] || [check isEqualToString:@" "])
        return NO;
    else
        return YES;
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void) showMsg:(NSString*)strMsg {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DomumLink" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (NSDate*) getDateFromString:(NSString*)aString withFormat:(NSString*)aFormat
{
	NSDate *retVal = nil;
	if (aFormat!=nil && [aFormat length] > 0)
    {
        NSDateFormatter *formatter = [GlobalVars sharedInstance].dateFormatterTime;
		[formatter setDateFormat:aFormat];
		retVal = [formatter dateFromString:aString];
    }
	
	return retVal;
}

// Format Phone Number
+ (NSString*)filteredDigitsOfPhoneNumber:(NSString*)string
{
    NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:set];
    
    return [components componentsJoinedByString:@""];
}

+ (NSString *)convertFormatedPhoneNumberToSimpleNumber:(NSString*)string {
    if(string.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSString *simpleNumber;
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    
    return simpleNumber;
}

+ (NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    // check if the number is to long
    //    if(simpleNumber.length>10) {
    //        // remove last extra chars.
    //        simpleNumber = [simpleNumber substringToIndex:10];
    //    }
    
    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if (simpleNumber.length > 12)
        simpleNumber = simpleNumber;
    else if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"$1-$2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else   // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}

+ (NSString *)formatStringWithSpace:(NSString *)str {
    BOOL isDetected = NO;
    NSInteger detectedIdx = 0;
    NSMutableArray *words = [NSMutableArray array];
    for (int i=0; i<str.length; i++) {
        BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[str characterAtIndex:i]];
        if (isDetected && isUppercase) {
            isDetected = NO;
            [words addObject:[str substringWithRange:NSMakeRange(detectedIdx, i-detectedIdx)]];
        }
        if (isUppercase) {
            isDetected = YES;
            detectedIdx = i;
        }
        if (i == str.length - 1) {
            [words addObject:[str substringWithRange:NSMakeRange(detectedIdx, i-detectedIdx+1)]];
        }
    }
    return [words componentsJoinedByString:@" "];
}

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (UIImage *)imageToUploadFromImage:(UIImage *)image {
    CGSize dstSize = image.size;
    if (image.size.width > kImageWidthToUpload)
        dstSize = CGSizeMake(kImageWidthToUpload, kImageWidthToUpload / image.size.width * image.size.height);
    image = [[image fixOrientation] imageByScalingAndCroppingForSize:dstSize];
    return image;
}

/**
 *  Update UI with the changed language
 */
+ (void)applyLanguageChange {
    NSString *lang = [GlobalVars sharedInstance].langCode == ELangEnglish ? @"en" : @"fr";
    LocalizationSetLanguage(lang);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSideMenu" object:nil];
}

@end
