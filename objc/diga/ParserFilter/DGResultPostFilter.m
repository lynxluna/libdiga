//
// DGResultPostFilter.m
// libDiga
//
// Created by Muhammad Sumyandityo Noor on Fri, Apr 06, 2012 02:57:30 PM PM UTC
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

#import "DGResultPostFilter.h"
#import "NSString+MindTalk.h"
#import "NSDictionary+MindTalk.h"

@implementation DGResultPostFilter

- (BOOL) isYoutube: youtubeURL
{
    NSURL *uTubeURL = [NSURL URLWithString:youtubeURL];
    NSString *host  = [uTubeURL host];
    
    NSRange range = [host rangeOfString:@"youtube.com"];
    return (range.location == NSNotFound ? NO : YES); 
}

- (NSString*) fixYoutubeURL:(NSString*) youtubeURL
{
    NSURL *uTubeURL = [NSURL URLWithString:youtubeURL];
    NSString *host  = [uTubeURL host];
    
    NSRange range = [host rangeOfString:@"youtube.com"];
    if (range.location == NSNotFound) {
        return youtubeURL;
    }
    
    NSString *queryString = [uTubeURL query];
    NSDictionary *qsDict = [NSDictionary dictionaryFromQueryString:queryString];
    
    return [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", [qsDict objectForKey:@"v"]];
    
}

- (NSArray*) extractURLFromString: (NSString*) sourceString
{
    if (sourceString == nil || [sourceString isKindOfClass:[NSNull class]]) {
        return [NSArray array];
    }
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:sourceString options:0 range:NSMakeRange(0, sourceString.length)];
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:0];
    for (NSTextCheckingResult *result in matches) {
        NSString *url = [result.URL absoluteString];
        if ([self isYoutube:url]) {
            url = [self fixYoutubeURL:url];
        }
        [urls addObject:url];
    }
    return urls;
}

- (NSArray*) filterDictionary: (NSDictionary*) dictionary
{
    NSArray *stream = [dictionary objectForKey:@"result"];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:stream.count];
    for (NSDictionary *post in stream) {
        NSMutableDictionary *mPost = [[post mutableCopy] autorelease];
        NSArray *urlParsed = [self extractURLFromString:[post objectForKey:@"message"]];
        [mPost setObject:urlParsed forKey:@"parsed_url"];
        [array addObject:mPost];
    }
    return array;
}


@end
