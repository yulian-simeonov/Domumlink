//
//  LocalizeHelper.h
//  DomumLink
//
//  Created by iOS Dev on 8/9/15.
//  Copyright (c) 2015 Yulian Simeonov. All rights reserved.
//

//LocalizeHelper.h

#import <Foundation/Foundation.h>

// some macros (optional, but makes life easy)

// Use "LocalizedString(key)" the same way you would use "NSLocalizedString(key,comment)"
#define LocalizedString(key) [[LocalizeHelper sharedLocalSystem] localizedStringForKey:(key)]

#define LocalizedArray(keysArray) [[LocalizeHelper sharedLocalSystem] localizedArrayForKeyArray:(keysArray)]

#define LocalizedDateString(key) [[LocalizeHelper sharedLocalSystem] localizedDateForDateString:(key)]

// "language" can be (for american english): "en", "en-US", "english". Analogous for other languages.
#define LocalizationSetLanguage(language) [[LocalizeHelper sharedLocalSystem] setLanguage:(language)]



@interface LocalizeHelper : NSObject

@property (nonatomic, strong) NSString* lang;
// a singleton:
+ (LocalizeHelper*) sharedLocalSystem;

// this gets the string localized:
- (NSString*) localizedStringForKey:(NSString*) key;

// this gets Array localized
- (NSArray *)localizedArrayForKeyArray:(NSArray *)keysArray;

//set a new language:
- (void) setLanguage:(NSString*) lang;

// this gets the Date localized
- (NSString *)localizedDateForDateString:(NSString *)dateString;

@end
