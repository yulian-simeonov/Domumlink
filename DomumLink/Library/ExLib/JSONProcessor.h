//
//  JSONProcessor.h
//  ExLib
//
//  Created by ExLib on 1/29/14.
//  Copyright (c) 2014 ExLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONPopulator.h"

@interface JSONProcessor : NSObject

+ (NSArray *) process:(NSArray *)jsonArray withPopulator:(JSONPopulator *)populator;

@end
