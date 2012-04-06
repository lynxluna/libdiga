//
// DGHTTPConnection.h
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

#import <Foundation/Foundation.h>
#import "DGRequestTypes.h"
@interface DGHTTPConnection : NSURLConnection {
    NSMutableData *_data;
    NSString *_identifier;
    NSURL *_URL;
    NSHTTPURLResponse *_response;
    
    DGRequestType _requestType;
    DGResponseType _responseType;
}

- (id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate
           requestType: (DGRequestType) requestType responseType: (DGResponseType) responseType;

- (void) resetDataLength;
- (void) appendData: (NSData*) data;


@property(nonatomic, assign, readonly) NSString       *identifier;
@property(nonatomic, retain, readonly) NSData         *data;
@property(nonatomic, assign, readonly) NSURL          *URL;
@property(nonatomic, assign, readonly) DGRequestType  requestType;
@property(nonatomic, assign, readonly) DGResponseType responseType;
@property(nonatomic, retain)           NSHTTPURLResponse *response;

@end