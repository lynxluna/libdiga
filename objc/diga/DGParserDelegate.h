// DGParserDelegate.h
// libDiga
//
// Created by Muhammad Sumyandityo Noor on Thu, Apr 05, 2012 07:04:44 PM UTC
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
// OAuth2Client library
// Portion of this software copyright (c) 2010 nxtbghng
// 

#ifndef DIGA_DGPARSERDELEGATE___H
#define DIGA_DGPARSERDELEGATE___H
#import <Foundation/Foundation.h>
#import "DGRequestTypes.h"

@protocol DGParserDelegate<NSObject>
@optional
- (void) parsingSucceededForRequest: (DGRequestType) requestType
                     ofResponseType: (DGResponseType) responseType
                  withParsedObjects: (NSArray*) parsedObjects;

- (void) parsingFailedForRequest: (DGRequestType) requestType
                  ofResponseType: (DGResponseType) responseTye
                       withError: (NSError*) error;

- (void) parsedObject: (NSDictionary*) parsedObject 
           forRequest: (DGRequestType) requestType
       ofResponseType: (DGResponseType) responseType;
@end

#endif

