//
//  JSONResponseSerializerWithData.h
//  ExLib
//
//  Created by ExLib on 2/28/14.
//  Copyright (c) 2014 ExLib. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
