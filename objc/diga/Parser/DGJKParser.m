//
// DGJKParser.m
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

#import "DGJKParser.h"
#import "DGParserFilter.h"
#import "DGParserDelegate.h"

#import "JSONKit.h" // relative to maintain submodule

@interface DGJKParser (PrivateMethods)

- (void) parsedObject: (NSDictionary*) dictionary;
- (void) parsingEnd;
@end

@implementation DGJKParser

+ (id) parserWithJSON:(NSData *)json delegate:(id)delegate connectionIdentifier:(NSString *)connectionIdentifier requestType:(DGRequestType)requestType responseType:(DGResponseType)responseType URL:(NSURL *)URL
{
    return [[[DGJKParser alloc] initWithJSON:json 
                                   delegate:delegate
                       connectionIdentifier:connectionIdentifier 
                                requestType:requestType 
                               responseType:responseType 
                                         URL:URL] autorelease];
}


- (id)  initWithJSON: (NSData*) json
            delegate: (id) delegate
connectionIdentifier: (NSString*) connectionIdentifier
         requestType: (DGRequestType) requestType
        responseType: (DGResponseType) responseType
                  URL: (NSURL*) URL
{
    self = [super init];
    
    if (self) {
        _json = [json retain];
        _identifier = [connectionIdentifier retain];
        _requestType = requestType;
        _responseType = responseType;
        _URL = [URL retain];
        _delegate = delegate;
        _parsedObjects = [[NSMutableArray alloc] initWithCapacity:0];
        
        if (_json && [_json length] > 0) {
            NSString *jsonString = [[NSString alloc] initWithData:_json encoding:NSUTF8StringEncoding];
            
            id results = [jsonString objectFromJSONString];
            MTLogDebug(@"#### JSON STRING: %@", jsonString);
            
            [jsonString release];
            
            
            DGParserFilter *filter = [DGParserFilter filterForRequestType:_requestType];
            if ([results isKindOfClass:[NSArray class]] &&
                [filter respondsToSelector:@selector(filterArray:)]) {
                _parsedObjects = [filter performSelector:@selector(filterArray:) withObject:results];
            }
            else if ([results isKindOfClass:[NSDictionary class]]) {
                if ([[results allKeys] containsObject:@"error"])
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(onAPIFailure:forRequestType:)]) {                    
                        NSMethodSignature *signature = [[_delegate class] instanceMethodSignatureForSelector:@selector(onAPIFailure:forRequestType:)];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        invocation.target = _delegate;
                        invocation.selector = @selector(onAPIFailure:forRequestType:);
                        NSDictionary *errorDict = [results objectForKey:@"error"];
                        [invocation setArgument:&errorDict atIndex:2];
                        [invocation setArgument:&_requestType atIndex:3];                    
                        [invocation invoke];
                        return self;
                    }
                }
                else if ([filter respondsToSelector:@selector(filterDictionary:)])
                {
                    _parsedObjects = [filter performSelector:@selector(filterDictionary:) withObject:results];
                }
            }
            [self parsingEnd];
        }
    }
    
    
    
    return self;
}


- (void) dealloc
{
    [_json release];
    [_identifier release];
    [_URL release];
    _delegate = nil;
    [super dealloc];
}

- (void) parsingEnd
{
    SEL delegateSelector = @selector(parsingSucceededForRequest:ofResponseType:withParsedObjects:);
    if ( _delegate && [_delegate respondsToSelector:delegateSelector]) {
        NSMethodSignature *signature = [[_delegate class] instanceMethodSignatureForSelector:delegateSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = _delegate;
        invocation.selector = delegateSelector;
        
        [invocation setArgument:&_requestType atIndex:2];
        [invocation setArgument:&_responseType atIndex:3];
        [invocation setArgument:&_parsedObjects atIndex:4];
        
        [invocation invoke];
    }
}

@end
