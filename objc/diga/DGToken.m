// DGToken.m
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


#import "DGToken.h"
#import "NSDictionary+MindTalk.h"

@implementation DGToken
@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize trackCode = _trackCode;

+ (DGToken*) tokenFromUserDefaults
{
    NSUserDefaults *sud  = [NSUserDefaults standardUserDefaults];
    NSString *at = [sud objectForKey:@"access_token"];
    NSString *rt = [sud objectForKey:@"refresh_token"];
    NSNumber *tc = [sud objectForKey:@"track_code"];
    
    if (at && at.length > 0 && rt && rt.length > 0 && tc) {
        DGToken *token = [[DGToken alloc] initWithAccessToken:at
                                        refreshToken:rt
                                           trackCode:tc.intValue];
        return [token autorelease];
    }
    else {
        return nil;
    }
}


+ (DGToken*) tokenFromQueryString:(NSString *)queryString
{
    DGToken *token = [[DGToken alloc] initWithQueryString:queryString];
    if (token) {
        return [token autorelease];
    }
    else {
        return nil;
    }
}

- (NSString*)description
{
    static NSString *fmt = @"access_token=%@&refresh_token=%@&tc=%d";
    return [NSString stringWithFormat:fmt, _accessToken, _refreshToken, 
            _trackCode];
}

- (id) initWithQueryString:(NSString *)queryString
{
    self = [super init];
    
    if (self) {
        NSDictionary *tokenDict = [NSDictionary 
                                   dictionaryFromQueryString:queryString];
        _accessToken = [[tokenDict objectForKey:@"access_token"] retain];
        _refreshToken = [[tokenDict objectForKey:@"refresh_token"] retain];
        _trackCode = [[tokenDict objectForKey:@"track_id"] intValue];
    }
    
    return self;
}

- (id) initWithAccessToken:(NSString *)accessToken 
              refreshToken:(NSString *)refreshToken 
                 trackCode:(unsigned int)trackCode
{
    self = [super init];
    
    if (self) {
        _accessToken = [accessToken retain];
        _refreshToken = [refreshToken retain];
        _trackCode = trackCode;
    }
    
    return self;
}

- (void) saveToUserDefaults
{
    NSUserDefaults *sud  = [NSUserDefaults standardUserDefaults];
    [sud setObject:_accessToken forKey:@"access_token"];
    [sud setObject:_refreshToken forKey:@"refresh_token"];
    [sud setObject:[NSNumber numberWithUnsignedInt:_trackCode] 
            forKey:@"track_code"];
    [sud synchronize];
    
}

- (void) dealloc
{
    [_refreshToken release];
    [_accessToken release];
    [super dealloc];
}

@end
