//
// DGBackend.h
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

#ifndef DIGA_DGBACKEND___H
#define DIGA_DGBACKEND___H

#import "DGBackendDelegate.h"
#import "DGParserDelegate.h"

typedef enum _MTUserScope {
    kMTUserScopeMember,
    kMTUserScopeMemberFounder,
    kMTUserScopeMemberAll,
} MTUserScope;

typedef  enum _MTPostKind {
    kMTPostKindAll,
    kMTPostKindArticle,
    kMTPostKindMind,
} MTPostKind;

typedef  enum _MTNotificationKind {
    kMTNotificationAll,
    kMTNotificationRead,
    kMTNotificationUnread
} MTNotificationKind;

typedef enum _MTSexKind {
    kMTSexKindFemale = 0,
    kMTSexKindMale = 1,
} MTSexKind;



@interface DGBackend : NSObject<DGParserDelegate> {
    id<DGBackendDelegate> _delegate;
    NSMutableDictionary *_connections;
    NSString *_clientName;
    NSString *_clientVersion;
    NSString *_clientURL;
    
    NSString *_APIDomain;
    NSString *_APIKey;
    NSString *_accessToken;
    NSString *_clientSecret;
    NSString *_clientId;
}

+ (DGBackend*) backendWithAPIDomain: (NSString*) domainName apiKey: (NSString*) apiKey delegate: (id) delegate;

- (id) initWithAPIDomain: (NSString*) domainName apiKey: (NSString*) apiKey delegate: (id) delegate;

@property(nonatomic, retain) NSString *accessToken;
@property(nonatomic, retain) NSString *clientSecret;
@property(nonatomic, retain) NSString *clientId;
@property(nonatomic, assign, readonly) NSDictionary *connections;

- (void) setDelegate: (id) delegate;


- (DGRequestType) requestTypeForConnection: (NSString*) identifier;
- (DGResponseType) responseTypeForConnection: (NSString*) identifier;
- (void) getPopularChannels : (NSUInteger) limit;
- (void) getNewestChannels  : (NSUInteger) limit offset: (NSUInteger) offset;
- (void) searchChannel      : (NSString*) name description: (NSString*) description;
- (void) getChannelsList    : (NSUInteger) limit offset: (NSUInteger) offset order: (NSString*) order;
- (void) getUserChannels    : (NSString*) userId scope: (MTUserScope) scope;
- (void) getRandomPeople    : (NSUInteger) offset limit: (NSUInteger) limit;

- (void) getChannelMembers  : (NSString*) channelId offset: (NSUInteger) offset limit: (NSUInteger) limit;
- (void) getUserInfoById    : (NSString*) userId;
- (void) getUserInfoByName  : (NSString*) userName;
- (void) getSupportingUsers : (NSString*) userId 
                       name : (NSString*) userName 
                     offset : (NSUInteger) offset 
                      limit : (NSUInteger) limit;
- (void) getSupportersForUser: (NSString*) userId
                         name: (NSString*) userName
                       offset: (NSUInteger) offset
                        limit: (NSUInteger) limit;
- (void) searchUser: (NSString*) name
           fullName: (NSString*) fullName
        description: (NSString*) personalDesc;

- (void) getChannelStream: (NSString*) channelId
                   offset: (NSUInteger) offset
                    limit: (NSUInteger) limit
                    order: (NSString*) order
                  sinceId: (NSString*) sinceId
                     toId: (NSString*) toId;

- (void) getUserStream: (NSString*) userId
                  name:(NSString*) name
                  kind: (MTPostKind) kind
                offset: (NSUInteger) offset
                 limit: (NSUInteger) limit
                 order: (NSString*) order
               sinceId: (NSString*) sinceId
                  toId: (NSString*) toId;

- (void) getPostResponses: (NSString*) postId
                   offset: (NSUInteger) offset
                    limit: (NSUInteger) limit
                    order: (NSString*) order;

- (void) joinChannelWithIdOrName: (NSString*) uidname;
- (void) leaveChannelWithIdOrName: (NSString*) uidname;
- (void) getUserMembershipStatus: (NSString*) uid forChannel: (NSString*) cid;
- (void) getUserSupportStatusForID: (NSString*) targetUser byUser: (NSString*) sourceUser;


#pragma mark authentic
- (void) getMyStreamWithOffset: (NSUInteger) offset
                         limit: (NSUInteger) limit
                       sinceId: (NSString*) sinceId
                          toId: (NSString*) toId;
- (void) getMyInfo;

- (void) postMindWithMessage: (NSString*) message
                   origin_id: (NSString*) origin;

- (void) updateProfileWithFullName: (NSString*) fullName
                               sex: (MTSexKind) gender
                          location: (NSString*) location
                         selfDescs: (NSString*) descs
                         birthDate: (NSDate*) birthDate;

- (void) updateProfileWithFullName: (NSString*) fullName
                          location: (NSString*) location
                         selfDescs: (NSString*) descs
                         birthDate: (NSDate*) birthDate;

- (void) changePasswordFromOldPass: (NSString*) oldPass
                       withNewPass:(NSString*) newPass;

- (void) postArticleWithTitle: (NSString*) title
                      message: (NSString*) message
                     originID: (NSString*) originID
                     keywords: (NSString*) keywords
                 thumbnailURL: (NSString*) thumbURL;

- (void) supportUserWithIdOrName:(NSString *)uidname;
- (void) unsupportWithIdOrName:(NSString *)uidname;
- (void) likePostWithId:(NSString *)postId;
- (void) unlikePostWithId:(NSString *)postId;
- (void) writeResponseWithPostID: (NSString*) postId
                        originID: (NSString*) originID
                         message: (NSString*) message;

- (void) isPostLiked: (NSString*) postId byUser: (NSString*) userId;

- (void) getMyNotificationsWithOffset: (NSInteger) offset
                                limit: (NSInteger) limit
                              sinceId: (NSString*) sinceID
                                 toId: (NSString*) toID
                                state: (MTNotificationKind) notificationKind;


@end

#endif

