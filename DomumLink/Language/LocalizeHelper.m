//
//  LocalizeHelper.m
//  DomumLink
//
//  Created by iOS Dev on 8/9/15.
//  Copyright (c) 2015 Yulian Simeonov. All rights reserved.
//

// LocalizeHelper.m
#import "LocalizeHelper.h"

// Singleton
static LocalizeHelper* SingleLocalSystem = nil;

// my Bundle (not the main bundle!)
static NSBundle* myBundle = nil;


@implementation LocalizeHelper


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (LocalizeHelper*) sharedLocalSystem {
    // lazy instantiation
    if (SingleLocalSystem == nil) {
        SingleLocalSystem = [[LocalizeHelper alloc] init];
    }
    return SingleLocalSystem;
}


//-------------------------------------------------------------
// initiating
//-------------------------------------------------------------
- (id) init {
    self = [super init];
    if (self) {
        // use systems main bundle as default bundle
        myBundle = [NSBundle mainBundle];
        self.lang = @"en";
    }
    return self;
}


//-------------------------------------------------------------
// translate a string
//-------------------------------------------------------------
// you can use this macro:
// LocalizedString(@"Text");
- (NSString*) localizedStringForKey:(NSString*) key {
    // this is almost exactly what is done when calling the macro NSLocalizedString(@"Text",@"comment")
    // the difference is: here we do not use the systems main bundle, but a bundle
    // we selected manually before (see "setLanguage")
    return [myBundle localizedStringForKey:key value:key table:nil];
}

- (NSArray *)localizedArrayForKeyArray:(NSArray *)keysArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<keysArray.count; i++) {
        [array addObject:[self localizedStringForKey:keysArray[i]]];
    }
    return (NSArray *)array;
}

// Localize Date String
- (NSString *)localizedDateForDateString:(NSString *)dateString {
    NSArray *array = [dateString componentsSeparatedByString:@" "];
    NSArray *resultArray = [self localizedArrayForKeyArray:array];
    return [resultArray componentsJoinedByString:@" "];
}

//-------------------------------------------------------------
// set a new language
//-------------------------------------------------------------
// you can use this macro:
// LocalizationSetLanguage(@"German") or LocalizationSetLanguage(@"de");
- (NSBundle*)getBundleForLang:(NSString*)lang{
    //get the path to the bundle
    NSString *bundlePath = [myBundle pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:lang];
    NSLog(@"bundlePath = %@",bundlePath);
    
    //load the bundle
    NSBundle *langBundle = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
    NSLog(@"langBundle = %@",langBundle);
    return langBundle;
}

- (void) setLanguage:(NSString*) lang {
    self.lang = lang;
    NSInteger langCode = [lang isEqualToString:@"en"] ? 0 : 1;
    [[GlobalVars sharedInstance] setLangCode:langCode];
    
    // path to this languages bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj" ];
    if (path == nil) {
        // there is no bundle for that language
        // use main bundle instead
        myBundle = [NSBundle mainBundle];
    } else {
        
        // use this bundle as my bundle from now on:
        myBundle = [NSBundle bundleWithPath:path];
        
        // to be absolutely shure (this is probably unnecessary):
        if (myBundle == nil) {
            myBundle = [NSBundle mainBundle];
        }
        
//        myBundle = [self getBundleForLang:@"er"];
    }
    
    [[GlobalVars sharedInstance] updateGlobalbarsWithLangCode];
}


@end