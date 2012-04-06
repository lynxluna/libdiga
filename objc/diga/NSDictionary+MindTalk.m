//
// NSDictionary+MindTalk.m
// libDiga
//
// Created by Muhammad Sumyandityo Noor on Thu, Apr 05, 2012 04:56:44 PM UTC
// Copyright 2012. All Rights Reserved
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in Software without restriction, including without limitation the 
// rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// This software is utilising JSONKit Library 
// Copyright (c) 2011 John Engelhart
//
// This software is utilising OAuth2Client Library
// Copyright (c) 2010 nxtbgthng
//

#import "NSDictionary+MindTalk.h"
#import "NSString+MindTalk.h"

@implementation NSDictionary (MindTalk)
- (NSString*) queryString
{
    NSMutableString *qs = [NSMutableString stringWithCapacity:0];
    
    if ([self count] == 0) {
        return nil;
    }
    
    NSArray *sortedArrays = [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *key in sortedArrays) {
        id val = [self valueForKey:key];
        if (val == nil) {
            continue;
        }
        NSString *strVal = nil;
        
        if ([val isKindOfClass:[NSNumber class]]) {
            strVal = [val performSelector:@selector(stringValue)];
        }
        else if ([val isKindOfClass:[NSString class]]) {
            strVal = (NSString*) val;
        }
        else {
            strVal = nil;
        }
        
        if ([key isKindOfClass:[NSString class]] && ( strVal && strVal.length > 0 ) ) {
            [qs appendString:[NSString stringWithFormat:@"%@=%@&", 
                              [key percentEncoded], 
                              [strVal percentEncoded]]];
        }
    }
    
    return [qs chop];
}

- (NSString*) queryStringWithBase:(NSString*) baseURL
{
    return [NSString stringWithFormat:@"%@?%@", baseURL, [self queryString]];
}

- (NSDictionary*) dictionaryByRemovingObjectForKey:(NSString *)key
{
    NSDictionary *result = self;
    if (key) {
        NSMutableDictionary *newParams = [[self mutableCopy] autorelease];
        [newParams removeObjectForKey:key];
        result = [[newParams copy] autorelease];
    }
    return result;
}

- (NSComparisonResult) compareStream: (NSDictionary*) otherObject
{
    NSInteger timestamp = [[self objectForKey:@"creation_time"] integerValue];
    NSInteger othertimestamp = [[otherObject objectForKey:@"creation_time"] integerValue];
    
    if (timestamp == othertimestamp) {
        return NSOrderedSame;
    }
    else if (timestamp < othertimestamp) {
        return NSOrderedDescending;
    }
    else if (timestamp > othertimestamp) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

+ (NSDictionary*) dictionaryFromQueryString:(NSString *)queryString
{
    NSArray *chunks = [[queryString percentDecoded] componentsSeparatedByString:@"&"];
    NSMutableDictionary *ret = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if ([chunks count] <=0) {
        return nil;
    }
    
    for (NSString *chunk in chunks) {
        NSArray *kvp = [chunk componentsSeparatedByString:@"="];
        [ret setObject:[kvp objectAtIndex:1] forKey:[kvp objectAtIndex:0]];
    }
    
    return ret;
}
@end
