// DGToken.h
// libDiga
//
// Created by Muhammad Sumyandityo Noor on Fri, Apr 06, 2012 10:12:52 PM UTC
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


#ifndef DIGA_DGTOKEN___H
#define DIGA_DGTOKEN___H

#import <Foundation/Foundation.h>

@interface DGToken : NSObject {
    
}

@property(nonatomic, retain, readonly) NSString *accessToken;
@property(nonatomic, retain, readonly) NSString *refreshToken;
@property(nonatomic, assign, readonly) unsigned int trackCode;

+ (DGToken*) tokenFromUserDefaults;
+ (DGToken*) tokenFromQueryString: (NSString*) queryString;

- (id) initWithAccessToken: (NSString*) accessToken
              refreshToken: (NSString*) refreshToken
                 trackCode: (unsigned int) trackCode;

- (id) initWithQueryString: (NSString*) queryString;

- (void) saveToUserDefaults;

@end

#endif

