//
//  JSONResponseSerializerWithData.m
//  ExLib
//
//  Created by ExLib on 2/28/14.
//  Copyright (c) 2014 ExLib. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
	id JSONObject = [super responseObjectForResponse:response data:data error:error];
	if (*error != nil) {
		NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
		if (data == nil) {
            //			// NOTE: You might want to convert data to a string here too, up to you.
            userInfo[JSONResponseSerializerWithDataKey] = nil;
		} else {
            //			// NOTE: You might want to convert data to a string here too, up to you.
            //NSString *bodyResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			//userInfo[JSONResponseSerializerWithDataKey] = data;
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if(jsonData != nil)
            {
                userInfo[JSONResponseSerializerWithDataKey] = jsonData;
            }
		}
		NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
		(*error) = newError;
	}
    
	return (JSONObject);
}

@end