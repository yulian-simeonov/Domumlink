//
//  JSONProcessor.h
//  ExLib
//
//  Created by ExLib on 1/29/14.
//  Copyright (c) 2014 ExLib. All rights reserved.
//

#import "JSONProcessor.h"

@implementation JSONProcessor
+ (NSArray *) process:(NSArray *)jsonArray withPopulator:(JSONPopulator *)populator
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSInteger arrayCount = [jsonArray count];
    for(int idx = 0; idx < arrayCount; idx++)
    {
        id item = [jsonArray objectAtIndex:idx];
        [items addObject:[[populator class] populateItem:item]];
    }
    
    return [items copy];
}

@end