//
// DGParserFilter.m
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

#import "DGParserFilter.h"
#import "DGResultChannelsFilter.h"
#import "DGResultFilter.h"
#import "DGResultArrayFilter.h"
#import "DGUserChannelFilter.h"
#import "DGUserMembersFilter.h"
#import "DGResultPostFilter.h"
#import "DGResponseFilter.h"
#import "DGStreamPostsFilter.h"

@implementation DGParserFilter

+ (DGParserFilter*) filterForRequestType: (DGRequestType) requestType
{
    switch (requestType)
    {
        case DGRequestNewestChannel:
        case DGRequestPopularChannel:
        case DGRequestChannelList:
            return [[[DGResultChannelsFilter alloc] init] autorelease];
        case DGRequestChannelInfo:
        case DGRequestRegisterNewUser:
        case DGRequestMyInfo:
            return [[[DGResultFilter alloc] init] autorelease];
        case DGRequestChannelSearch:
        case DGRequestUserSupporting:
        case DGRequestUserSupporter:
        case DGRequestUserSearch:
        case DGRequestRandomPeople:
        case DGRequestNotifications:
            return [[[DGResultArrayFilter alloc] init] autorelease];
        case DGRequestUserChannel:
            return [[[DGUserChannelFilter alloc] init] autorelease];
        case DGRequestChannelMembers:
            return [[[DGUserMembersFilter alloc] init] autorelease];
        case DGRequestChannelStream:
        case DGRequestUserPosts:
            return [[[DGResultPostFilter alloc] init] autorelease];
        case DGRequestMyStream:
            return [[[DGStreamPostsFilter alloc] init] autorelease];
        case DGRequestPostComments:
            return [[[DGResponseFilter alloc] init] autorelease];
        default:
            return [[[DGParserFilter alloc] init] autorelease];
    }
}

- (NSArray*) filterArray:(NSArray *)results
{
    return results;
}

- (NSArray*) filterDictionary:(NSDictionary *)dictionary
{
    return [NSArray arrayWithObject:dictionary];
}

@end
