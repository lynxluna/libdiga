//
// DGRequestTypes.h
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

#ifndef DIGA_DGREQUESTTYPES___H
#define DIGA_DGREQUESTTYPES___H

typedef enum _DGRequestType
{
    DGRequestPopularChannel = 0,
    DGRequestNewestChannel  = 1,
    DGRequestRandomPeople   = 2,
    DGRequestChannelStream  = 3,
    DGRequestChannelInfo    = 4,
    DGRequestChannelSearch  = 5,
    DGRequestChannelList    = 6,
    DGRequestUserChannel    = 7,
    
    DGRequestChannelMembers = 8,
    DGRequestUserInfo       = 9,
    DGRequestUserSupporting = 10,
    DGRequestUserSupporter  = 11,
    DGRequestUserSearch     = 12,
    DGRequestMyInfo         = 13,
    DGRequestUserPeople     = 14,
    
    DGRequestUserPosts       = 16,
    
    DGRequestPostComments    = 17,
    
    DGRequestMyStream        = 18,
    DGRequestIsMember        = 19,
    
    DGRequestRegisterNewUser = 20,
    
    DGRequestJoinChannel     = 21,
    DGRequestLeaveChannel    = 22,
    
    DGRequestWriteMind       = 23,
    DGRequestUpdateProfile   = 24,
    DGRequestChangePassword  = 25,
    DGRequestCreateArticle   = 26,
    DGRequestSupportUser     = 27,
    DGRequestUnsupportUser   = 28,
    DGRequestLikePost        = 29,
    DGRequestUnlikePost      = 30,
    
    DGRequestGetPostLikes    = 31,
    DGRequestGetComments     = 32,
    DGRequestIsSupport       = 33,
    
    DGRequestIsPostLiked     = 34,
    DGRequestNotifications   = 35,
    
    DGRequestTokenFromCode   = 36,
    
    DGRequestTypeGeneric     = 1000,
    
    DGRequestCount
    
} DGRequestType;


typedef enum _DGResponseType
{
    DGResponseChannelsList   = 0,
    DGResponsePeopleList     = 1,
    DGResponseStreamList     = 2,
    DGResponseCommentList    = 3,
    DGResponseReturnResult   = 4,
    DGResponseNotificationList = 5,
    DGResponseToken          = 6,
    
    DGResponseTypeGeneric  = 1000,
    
    DGResponseCount
} DGResponseType;

#endif

