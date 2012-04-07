//
// DGBackend.m
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

#import "DGBackend.h"
#import "DGHTTPConnection.h"
#import "DGJKParser.h"
#import "NSDictionary+MindTalk.h"
#import "DGToken.h"

@interface DGBackend(PrivateMethods)

- (NSString*) sendRequestWithMethod: (NSString*) method
                               path: (NSString*) path
                    queryParameters: (NSDictionary*) params
                        requestType: (DGRequestType) requestType
                       responseType: (DGResponseType) responseType;

- (NSMutableURLRequest*) baseRequestWithMethod: (NSString*) method
                                          path: (NSString*) path
                                   requestType: (DGRequestType) requestType
                               queryParameters: (NSDictionary*)params;
- (void) parseDataForConnection: (DGHTTPConnection*) connection;
- (void) parseTokenForConnection: (DGHTTPConnection*) connection;

@end


@implementation DGBackend
@synthesize accessToken = _accessToken;
@synthesize clientSecret = _clientSecret;
@synthesize clientId = _clientId;
@synthesize connections = _connections;

- (void) setDelegate:(id)delegate
{
    _delegate = delegate;
}


- (DGRequestType) requestTypeForConnection:(NSString *)identifier
{
    return [[_connections objectForKey:identifier] requestType];
}

- (DGResponseType) responseTypeForConnection:(NSString *)identifier
{
    return [[_connections objectForKey:identifier] responseType];
}

+ (DGBackend*) backendWithAPIDomain:(NSString *)domainName apiKey:(NSString *)apiKey delegate:(id)delegate
{
    return [[[DGBackend alloc] initWithAPIDomain:domainName 
                                          apiKey:apiKey 
                                        delegate:delegate] autorelease];
}

- (id) initWithAPIDomain:(NSString *)domainName apiKey:(NSString *)apiKey delegate:(id)delegate
{
    self = [super init];
    if (self) {
        _APIDomain = [domainName retain];
        _APIKey    = [apiKey retain];
        _delegate  = delegate;
    }
    return self;
}

- (void) dealloc
{
    NSEnumerator *connEnum = [_connections keyEnumerator];
    NSString *key;
    while ((key = [connEnum nextObject])) {
        [[_connections objectForKey:key] cancel];
    }
    
    [_connections removeAllObjects];
    [_connections release];
    
    [_APIDomain release];
    [_APIKey release];
    [super dealloc];
}

- (void) parsingSucceededForRequest:(DGRequestType) requestType ofResponseType:(DGResponseType)responseTye withParsedObjects:(NSArray *)parsedObjects
{
    SEL delegateSelector = nil;
    
    switch (responseTye) {
        case DGResponseChannelsList:
            if (_delegate && [_delegate respondsToSelector:@selector(channelListReceived:forRequestType:)]) {
                delegateSelector = @selector(channelListReceived:forRequestType:);
            }
            break;
        case DGResponsePeopleList:
            if (_delegate && [_delegate respondsToSelector:@selector(userListReceived:forRequestType:)]) {
                delegateSelector = @selector(userListReceived:forRequestType:);
            }
            break;
        case DGResponseStreamList:
            if (_delegate && [_delegate respondsToSelector:@selector(streamListReceived:forRequestType:)]) {
                delegateSelector = @selector(streamListReceived:forRequestType:);
            }
            break;
        case DGResponseCommentList:
            if (_delegate && [_delegate respondsToSelector:@selector(commentsListReceived:forRequestType:)]) {
                delegateSelector = @selector(commentsListReceived:forRequestType:);
            }
            break;
        case DGResponseReturnResult:
            if (_delegate && [_delegate respondsToSelector:@selector(resultReceived:forRequestType:)]) {
                delegateSelector = @selector(resultReceived:forRequestType:);
            }
            break;
        case DGResponseNotificationList:
            if (_delegate && [_delegate respondsToSelector:@selector(notificationListReceived:forRequestType:)]) {
                delegateSelector = @selector(notificationListReceived:forRequestType:);
            }
            break;
        default:
            if (_delegate && [_delegate respondsToSelector:@selector(onGenericResultReceived:forRequestType:)]) {
                delegateSelector = @selector(onGenericResultReceived:forRequestType:);
            }
            break;
    }
    
    if (delegateSelector == nil) {
        return;
    }
    
    NSMethodSignature *signature = [[_delegate class] instanceMethodSignatureForSelector:delegateSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = _delegate;
    invocation.selector = delegateSelector;
    
    [invocation setArgument:&parsedObjects atIndex:2];
    [invocation setArgument:&requestType atIndex:3];
    [invocation invoke];
}


#pragma mark MTHTTPConnectionDelegate

- (void) connection:(DGHTTPConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [connection resetDataLength];
    
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    [connection setResponse:httpResponse];
    NSInteger statusCode = [httpResponse statusCode];
    
    if (statusCode == 304) {
        [self parsingSucceededForRequest:[connection requestType]
                          ofResponseType:[connection responseType]
                       withParsedObjects:[NSArray array]];
        [connection cancel];
        NSString *ident = [connection identifier];
        [_connections removeObjectForKey:ident];
        if ( _delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
            [_delegate performSelector:@selector(connectionFinished:) withObject:ident];
        }
    }
}

- (void) connection:(DGHTTPConnection *)connection didReceiveData:(NSData *)data
{
    [connection appendData:data];
}

- (void) connection:(DGHTTPConnection *)connection didFailWithError:(NSError *)error
{
    NSString *ident = [connection identifier];
    
    if ( _delegate && [_delegate respondsToSelector:@selector(requestFailed:withError:)]) {
        [_delegate performSelector:@selector(requestFailed:withError:) withObject:ident withObject:error];
    }
    
    [_connections removeObjectForKey:ident];
    if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
        [_delegate performSelector:@selector(connectionFinished:) withObject:ident];
    }
}

- (void) connectionDidFinishLoading:(DGHTTPConnection *)connection
{
    NSInteger statusCode = [[connection response] statusCode];
    MTLogDebug(@"Request Type = %d", [connection requestType]);
    
    if (statusCode > 400) {
        NSData *receivedData = [connection data];
        NSString *body = [receivedData length] > 0 ? [NSString stringWithUTF8String:[receivedData bytes]] : @"";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[connection response], @"response",
                                  body, @"body",
                                  nil];
        NSError *error = [NSError errorWithDomain:@"HTTP"
                                             code:statusCode 
                                         userInfo:userInfo];
        if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:withError:)]) {
            [_delegate performSelector:@selector(requestFailed:withError:) 
                            withObject:connection.identifier
                            withObject:error];
        }
        
        [connection cancel];
        NSString *ident = [connection identifier];
        [_connections removeObjectForKey:ident];
        if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
            [_delegate performSelector:@selector(connectionFinished:) withObject:ident];
        }
        
        return;
    }
    
    NSString *connid = [connection identifier];
    
    if (_delegate && [_delegate respondsToSelector:@selector(requestSucceeded:)]) {
        [_delegate performSelector:@selector(requestSucceeded:) withObject:connid];
    }
    NSData *receivedData = [connection data];
    
    if (receivedData) {
        if (connection.requestType != DGRequestTokenFromCode) {
            [self parseDataForConnection:connection];
        }
        else {
            [self parseTokenForConnection:connection];
        }
    }
    
    [_connections removeObjectForKey:connid];
    if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
        [_delegate performSelector:@selector(connectionFinished:) withObject:connid];
    }
}

- (void) parseDataForConnection:(DGHTTPConnection *)connection
{
    NSData *jsonData = [[[connection data] copy] autorelease];
    NSString *ident  = [[[connection identifier] copy] autorelease];
    DGRequestType requestType = [connection requestType];
    DGResponseType responseType = [connection responseType];
    
    
    NSURL *URL = [connection URL];
    [DGJKParser parserWithJSON:jsonData 
                      delegate:self 
          connectionIdentifier:ident 
                   requestType:requestType 
                  responseType:responseType 
                           URL:URL];
}

- (void) parseTokenForConnection:(DGHTTPConnection *)connection
{
    NSData *tokenData = [[[connection data] copy] autorelease];
    NSString *tokenString = [[NSString alloc] initWithData:tokenData 
                                                  encoding:NSUTF8StringEncoding];
    
    DGRequestType reqType = connection.requestType;
    
    DGToken *token = [DGToken tokenFromQueryString:tokenString];
    
    SEL delegateSelector = nil;
    
    if (_delegate && ![_delegate isKindOfClass:[NSNull class]] &&
        [_delegate respondsToSelector:@selector(tokenReceived:forRequestType:)])
    {
        delegateSelector = @selector(tokenReceived:forRequestType:);
    }
    
    if (delegateSelector == nil) {
        return;
    }
    
    NSMethodSignature *signature = [[_delegate class] instanceMethodSignatureForSelector:delegateSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = _delegate;
    invocation.selector = delegateSelector;
    
    [invocation setArgument:&token atIndex:2];
    [invocation setArgument:&reqType atIndex:3];
    [invocation invoke];
    
    
    [tokenString release];
}

#pragma mark utility

- (NSString*) sendTokenRequestFromCode: (NSString*) code
{
    NSString *urlStr = 
    [NSString stringWithFormat:@"http://auth.mindtalk.com/access_token?code=%@&client_secret=%@",
                                                   code, _clientSecret];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    DGHTTPConnection *connection = nil;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    connection = [[DGHTTPConnection alloc] initWithRequest:req
                                                  delegate:self 
                                               requestType:DGRequestTokenFromCode
                                              responseType:DGResponseToken];
    if (!connection) {
        return  nil;
    }
    else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    if ( _delegate && [_delegate respondsToSelector:@selector(connectionStarted:)] ) {
        [_delegate performSelector:@selector(connectionStarted:) withObject:[connection identifier]];
    }
    
    return [connection identifier];
}

- (NSString*) sendRequestWithMethod:(NSString *)method path:(NSString *)path queryParameters:(NSDictionary *)params requestType:(DGRequestType)requestType responseType:(DGResponseType)responseType
{
    NSMutableURLRequest *request = [self baseRequestWithMethod:method 
                                                          path:path 
                                                   requestType:requestType 
                                               queryParameters:params];
    DGHTTPConnection *connection = nil;
    
    connection = [[DGHTTPConnection alloc] initWithRequest:request 
                                                  delegate:self 
                                               requestType:requestType 
                                              responseType:responseType];
    if (!connection) {
        return  nil;
    }
    else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    if ( _delegate && [_delegate respondsToSelector:@selector(connectionStarted:)] ) {
        [_delegate performSelector:@selector(connectionStarted:) withObject:[connection identifier]];
    }
    
    return [connection identifier];
}

- (NSMutableURLRequest*) baseRequestWithMethod:(NSString *)method path:(NSString *)path requestType:(DGRequestType)requestType queryParameters:(NSDictionary *)params
{
    NSString *contentType = [params objectForKey:@"Content-Type"];
    if (contentType) {
        params = [params dictionaryByRemovingObjectForKey:@"Content-Type"];
    }
    else {
        contentType = @"application/x-www-form-urlencoded";
    }
    
    NSMutableDictionary *qsDict = nil;
    if (params) {
        qsDict = [[params mutableCopy] autorelease];
    }
    else {
        qsDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    [qsDict setValue:@"json" forKey:@"rf"];
    
    if (_accessToken) {
        [qsDict setValue:_accessToken forKey:@"access_token"];
    }
    
    if (_APIKey) {
        [qsDict setValue:_APIKey forKey:@"api_key"];
    }
    
    
    NSString *fullPath = [path stringByAddingPercentEscapesUsingEncoding:NSNonLossyASCIIStringEncoding];
    
    if (qsDict && ![method isEqualToString:@"POST"]) {
        fullPath = [qsDict queryStringWithBase:fullPath];
    }
    
    NSString *finalString = [NSString stringWithFormat:@"http://%@/%@", _APIDomain, fullPath];
    NSURL *finalURL = [NSURL URLWithString:finalString];
    
    if (!finalURL) {
        return nil;
    }
    
    
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:finalURL];
    
#if DEBUG
    NSLog(@"Final URL: %@", finalURL);
#endif
    
    if (method) {
        [_request setHTTPMethod:method];
    }
    
    [_request setHTTPShouldHandleCookies:NO];
    [_request setValue:_clientName forHTTPHeaderField:@"X-Mindtalk-Client"];
    [_request setValue:_clientVersion forHTTPHeaderField:@"X-Mindtalk-Client-Version"];
    [_request setValue:_clientURL forHTTPHeaderField:@"X-Mindtalk-Client-URL"];
    
    [_request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    if (method && [method isEqualToString:@"POST"]) {
        [_request setHTTPBody:[[qsDict queryString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return _request;
    
}


#pragma mark mindtalkapi

- (void) getAccessTokenFromCode:(NSString *)code
{
    if (code && [code isKindOfClass:[NSString class]] &&
        code.length > 0) 
    {
        [self sendTokenRequestFromCode:code];
    }
}

- (void) getPopularChannels:(NSUInteger)limit
{
    NSString *path = @"v1/channel/popular";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:(limit <= 0 ) ? 10 : limit], @"limit",
                            nil];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestPopularChannel 
                   responseType:DGResponseChannelsList];
}

- (void) getNewestChannels:(NSUInteger)limit offset:(NSUInteger)offset
{
    NSString *path = @"v1/channel/newest";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInteger:limit], @"limit",
                            [NSNumber numberWithInteger:offset], @"offset",
                            nil];
    
    [self sendRequestWithMethod:nil 
                           path:path
                queryParameters:params
                    requestType:DGRequestNewestChannel
                   responseType:DGResponseChannelsList];
}

- (void) searchChannel: (NSString*) name description: (NSString*) description
{
    NSString *path = @"v1/channel/search";
    NSDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:name forKey:@"name"];
    [params setValue:description forKey:@"desc"];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestChannelSearch 
                   responseType:DGResponseChannelsList];
}

- (void) getChannelsList: (NSUInteger) limit offset: (NSUInteger) offset order: (NSString*) order
{
    NSString *path = @"v1/channel/list";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    [params setValue:order forKey:@"order"];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestChannelList 
                   responseType:DGResponseChannelsList];
}

- (void) getUserChannels: (NSString*) userId scope: (MTUserScope) scope
{
    NSString *path = @"v1/user/channels";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:userId forKey:@"user_id"];
    switch (scope) {
        case kMTUserScopeMember:
            [params setValue:@"member" forKey:@"scope"];
            break;
        case kMTUserScopeMemberAll:
            [params setValue:@"all" forKey:@"scope"];
            break;
        case kMTUserScopeMemberFounder:
            [params setValue:@"founder" forKey:@"scope"];
        default:
            break;
    }
    
    [self sendRequestWithMethod:nil 
                           path:path
                queryParameters:params 
                    requestType:DGRequestUserChannel 
                   responseType:DGResponseChannelsList];
}

- (void) getChannelMembers:(NSString *)channelId offset:(NSUInteger)offset limit:(NSUInteger)limit
{
    NSString *path = @"v1/channel/members";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:channelId forKey:@"id"];
    [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInt:limit] forKey:@"limit"];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestChannelMembers 
                   responseType:DGResponsePeopleList];
}

/* only one parameters required, that's why we make a utility method */
- (void) getUserInfoById:(NSString *)userId name: (NSString*) name
{
    NSString *path = @"v1/user/info";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (userId) {
        [params setValue:userId forKey:@"id"];
    }
    else if (name) {
        [params setValue:name forKey:@"name"];
    }
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestUserInfo 
                   responseType:DGResponsePeopleList];
}

- (void) getUserInfoById:(NSString *)userId
{
    [self getUserInfoById:userId name:nil];
}

- (void) getUserInfoByName:(NSString *)userName
{
    [self getUserInfoById:nil name:userName];
}

- (void) getSupportingUsers:(NSString *)userId 
                       name:(NSString *)userName 
                     offset:(NSUInteger)offset 
                      limit:(NSUInteger)limit
{
    NSString *path = @"v1/user/supporting";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setValue:userId forKey:@"id"];
    [params setValue:userName forKey:@"name"];
    [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    if (limit > 0) {
        [params setValue:[NSNumber numberWithInt:limit] forKey:@"limit"];
    }    
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params
                    requestType:DGRequestUserSupporting
                   responseType:DGResponsePeopleList];
}

- (void) getSupportersForUser:(NSString *)userId 
                         name:(NSString *)userName 
                       offset:(NSUInteger)offset 
                        limit:(NSUInteger)limit
{
    NSString *path = @"v1/user/supporters";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setValue:userId forKey:@"id"];
    [params setValue:userName forKey:@"name"];
    [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInt:limit] forKey:@"limit"];
    
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params
                    requestType:DGRequestUserSupporter
                   responseType:DGResponsePeopleList];
}

- (void) searchUser:(NSString *)name fullName:(NSString *)fullName description:(NSString *)personalDesc
{
    NSString *path = @"v1/user/search";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:name forKey:@"name"];
    [params setValue:fullName forKey:@"full_name"];
    [params setValue:personalDesc forKey:@"personal_desc"];
    
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params
                    requestType:DGRequestUserSearch
                   responseType:DGResponsePeopleList];
}

- (void) getChannelStream:(NSString *)channelId 
                   offset:(NSUInteger)offset 
                    limit:(NSUInteger)limit 
                    order:(NSString *)order 
                  sinceId:(NSString *)sinceId 
                     toId:(NSString *)toId
{
    NSString *path = @"v1/channel/stream";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    [params setValue:channelId forKey:@"id"];
    [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInt:limit]  forKey:@"limit"];
    [params setValue:order forKey:@"order"];
    [params setValue:sinceId forKey:@"since_id"];
    [params setValue:toId forKey:@"to_id"];
    
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params
                    requestType:DGRequestChannelStream
                   responseType:DGResponseStreamList];
}

- (void) getUserStream:(NSString *)userId 
                  name:(NSString *)name 
                  kind:(MTPostKind)kind 
                offset:(NSUInteger)offset 
                 limit:(NSUInteger)limit 
                 order:(NSString *)order 
               sinceId:(NSString *)sinceId 
                  toId:(NSString *)toId
{
    NSString *kindString = ( kind == kMTPostKindAll ? nil : ( kind == kMTPostKindArticle ? @"Article" : @"Mind" ) );
    NSString *path = @"v1/user/posts";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    [params setValue:userId forKey:@"id"];
    [params setValue:name forKey:@"name"];
    [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInt:limit]  forKey:@"limit"];
    [params setValue:order forKey:@"order"];
    [params setValue:sinceId forKey:@"since_id"];
    [params setValue:toId forKey:@"to_id"];
    [params setValue:kindString forKey:@"kind"];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestUserPosts 
                   responseType:DGResponseStreamList];
    
}

- (void) getPostResponses:(NSString *)postId 
                   offset:(NSUInteger)offset 
                    limit:(NSUInteger)limit 
                    order:(NSString *)order
{
    NSString *path = @"v1/post/responses";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setValue:postId forKey:@"post_id"];
    if (offset > 0) {
        [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    }
    if (limit > 0) {
        [params setValue:[NSNumber numberWithInt:limit]  forKey:@"limit"];
    }
    
    if (order && order.length > 0 && ![order isKindOfClass:[NSNull class]]) {
        [params setValue:order forKey:@"order"];
    }
    
    [self sendRequestWithMethod:nil
                           path:path
                queryParameters:params
                    requestType:DGRequestPostComments
                   responseType:DGResponseCommentList];
}

- (void) getMyStreamWithOffset:(NSUInteger)offset 
                         limit:(NSUInteger)limit 
                       sinceId:(NSString *)sinceId 
                          toId:(NSString *)toId
{
    NSString *path = @"v1/my/stream";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    if (limit > 0) {
        [params setValue:[NSNumber numberWithInt:limit]  forKey:@"limit"];
    }
    [params setValue:sinceId forKey:@"since_id"];
    [params setValue:toId forKey:@"to_id"];
    
    
    [self sendRequestWithMethod:nil
                           path:path
                queryParameters:params
                    requestType:DGRequestMyStream
                   responseType:DGResponseStreamList];
}

- (void) getRandomPeople:(NSUInteger)offset 
                   limit:(NSUInteger)limit
{
    NSString *path = @"v1/user/peoples";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (offset > 0) {
        [params setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    }
    if (limit > 0) {
        [params setValue:[NSNumber numberWithInt:limit]  forKey:@"limit"];
    }
    
    
    [self sendRequestWithMethod:nil
                           path:path
                queryParameters:params
                    requestType:DGRequestRandomPeople
                   responseType:DGResponsePeopleList];
}

- (void) registerUserWithName:(NSString *)name 
                     fullName:(NSString *)fullName 
                          sex:(MTSexKind)sexKind 
                     password:(NSString *)password 
                     birthDay:(NSDate *)birthDay 
                        email:(NSString *)email
{
    NSString *path = @"v1/user/register";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:name forKey:@"name"];
    [params setObject:fullName forKey:@"full_name"];
    [params setObject:(sexKind == kMTSexKindMale ? @"male" : @"female") 
               forKey:@"sex"];
    [params setObject:password forKey:@"password"];
    
    /* date format yyyy-mm-dd */
    NSDateFormatter *frmTgl = [[[NSDateFormatter alloc] init] autorelease];
    [frmTgl setDateFormat:@"yyyy-MM-dd"];
    
    [params setObject:[frmTgl stringFromDate:birthDay] forKey:@"birth_date"];
    [params setObject:email forKey:@"email"];
    
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    [self sendRequestWithMethod:@"POST" 
                           path:path
                queryParameters:params
                    requestType:DGRequestRegisterNewUser
                   responseType:DGResponsePeopleList];
}

- (void) getMyInfo
{
    NSString *path = @"v1/my/info";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    [self sendRequestWithMethod:nil 
                           path:path
                queryParameters:params
                    requestType:DGRequestMyInfo
                   responseType:DGResponsePeopleList];
}

- (void) joinChannelWithIdOrName:(NSString *)uidname
{
    NSString *path = @"v1/channel/join";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (uidname && uidname.length > 0) {
        [params setObject:uidname forKey:@"uidname"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestJoinChannel
                   responseType:DGResponseReturnResult];
}

- (void) leaveChannelWithIdOrName: (NSString*) uidname
{
    NSString *path = @"v1/channel/leave";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (uidname && uidname.length > 0) {
        [params setObject:uidname forKey:@"uidname"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestLeaveChannel
                   responseType:DGResponseReturnResult];
}

- (void) getUserMembershipStatus:(NSString *)uid forChannel:(NSString *)cid
{
    NSString *path = @"v1/channel/is_member";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (uid && uid.length > 0) {
        [params setObject:uid forKey:@"user_id"];
    }
    
    if (cid && cid.length > 0) {
        [params setObject:cid forKey:@"channel_id"];
    }
    
    [self sendRequestWithMethod:nil
                           path:path 
                queryParameters:params
                    requestType:DGRequestIsMember
                   responseType:DGResponseReturnResult];
}

- (void) postMindWithMessage:(NSString *)message origin_id:(NSString *)origin
{
    NSString *path = @"v1/post/write_mind";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    
    if (!message || message.length == 0 || !origin || origin.length == 0) {
        return;
    }
    
    [params setObject:message forKey:@"message"];
    [params setObject:origin forKey:@"origin_id"];
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestWriteMind
                   responseType:DGResponseTypeGeneric];
}

- (void) updateProfileWithFullName: (NSString*) fullName
                               sex: (MTSexKind) gender
                          location: (NSString*) location
                         selfDescs: (NSString*) descs
                         birthDate: (NSDate*) birthDate
{
    NSString *path = @"/v1/user/update_profile";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    
    [params setObject:fullName forKey:@"full_name"];
    [params setObject:(gender == kMTSexKindMale ? @"male" : @"female") 
               forKey:@"sex"];
    
    if (birthDate != nil) {
        /* date format yyyy-mm-dd */
        NSDateFormatter *frmTgl = [[[NSDateFormatter alloc] init] autorelease];
        [frmTgl setDateFormat:@"yyyy-MM-dd"];
        
        [params setObject:[frmTgl stringFromDate:birthDate] forKey:@"birth_date"];
    }
    
    if (descs && descs.length > 0) {
        [params setObject:descs forKey:@"self_descs"];
    }
    
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestUpdateProfile
                   responseType:DGResponseTypeGeneric];
    
}

- (void) updateProfileWithFullName: (NSString*) fullName
                          location: (NSString*) location
                         selfDescs: (NSString*) descs
                         birthDate: (NSDate*) birthDate
{
    NSString *path = @"/v1/user/update_profile";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    
    [params setObject:fullName forKey:@"full_name"];
    
    if (birthDate != nil) {
        /* date format yyyy-mm-dd */
        NSDateFormatter *frmTgl = [[[NSDateFormatter alloc] init] autorelease];
        [frmTgl setDateFormat:@"yyyy-MM-dd"];
        
        [params setObject:[frmTgl stringFromDate:birthDate] forKey:@"birth_date"];
    }
    
    if (descs && descs.length > 0) {
        [params setObject:descs forKey:@"self_descs"];
    }
    
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestUpdateProfile
                   responseType:DGResponseTypeGeneric];
    
}

- (void) changePasswordFromOldPass:(NSString *)oldPass 
                       withNewPass:(NSString *)newPass
{
    NSString *path = @"/v1/user/update_password";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    
    [params setObject:oldPass forKey:@"old_pass"];
    [params setObject:newPass forKey:@"new_pass"];
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestChangePassword
                   responseType:DGResponseTypeGeneric];
}

- (void) postArticleWithTitle: (NSString*) title
                      message: (NSString*) message
                     originID: (NSString*) originID
                     keywords: (NSString*) keywords
                 thumbnailURL: (NSString*) thumbURL
{
    NSString *path = @"v1//post/create_article";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    
    [params setObject:title forKey:@"title"];
    [params setObject:message forKey:@"message"];
    [params setObject:originID forKey:@"origin_id"];
    
    if (keywords && keywords.length > 0) {
        [params setObject:originID forKey:@"keywords"];
    }
    
    if ([NSURL URLWithString:thumbURL] != nil) {
        [params setObject:thumbURL forKey:@"thumbnail_url"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestCreateArticle
                   responseType:DGResponseTypeGeneric];
}

- (void) supportUserWithIdOrName:(NSString *)uidname
{
    NSString *path = @"v1/user/support";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (uidname && uidname.length > 0) {
        [params setObject:uidname forKey:@"uidname"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestSupportUser
                   responseType:DGResponseTypeGeneric];
}
- (void) unsupportWithIdOrName:(NSString *)uidname
{
    NSString *path = @"v1/user/unsupport";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (uidname && uidname.length > 0) {
        [params setObject:uidname forKey:@"uidname"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestUnsupportUser
                   responseType:DGResponseTypeGeneric];
}

- (void) likePostWithId:(NSString *)postId
{
    NSString *path = @"v1/post/like_post";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (postId && postId.length > 0) {
        [params setObject:postId forKey:@"post_id"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestLikePost
                   responseType:DGResponseTypeGeneric];
}

- (void) unlikePostWithId:(NSString *)postId
{
    NSString *path = @"v1/post/unlike_post";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (postId && postId.length > 0) {
        [params setObject:postId forKey:@"post_id"];
    }
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestUnlikePost
                   responseType:DGResponseTypeGeneric];
}

- (void) writeResponseWithPostID: (NSString*) postId
                        originID: (NSString*) originID
                         message: (NSString*) message
{
    NSString *path = @"v1/post/write_response";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.clientId != nil && self.clientSecret != nil) {
        [params setObject:self.clientId forKey:@"client_id"];
        [params setObject:self.clientSecret forKey:@"client_secret"];
    }
    
    if (postId && postId.length > 0) {
        [params setObject:postId forKey:@"post_id"];
    }
    
    [params setObject:originID forKey:@"origin_id"];
    [params setObject:message forKey:@"message"];
    
    [self sendRequestWithMethod:@"POST"
                           path:path 
                queryParameters:params
                    requestType:DGRequestPostComments
                   responseType:DGResponseTypeGeneric];
}


- (void) getUserSupportStatusForID:(NSString *)targetUser byUser:(NSString *)sourceUser
{
    NSString *path = @"v1/user/is_support";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [params setObject:targetUser forKey:@"s_user_id"];
    [params setObject:sourceUser forKey:@"t_user_id"];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestIsSupport 
                   responseType:DGResponseTypeGeneric];
}

- (void) isPostLiked:(NSString *)postId byUser:(NSString *)userId
{
    NSString *path = @"v1/post/is_post_liked";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [params setObject:userId forKey:@"user_id"];
    [params setObject:postId forKey:@"post_id"];
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestIsPostLiked 
                   responseType:DGResponseTypeGeneric];
}

- (void) getMyNotificationsWithOffset:(NSInteger)offset 
                                limit:(NSInteger)limit 
                              sinceId:(NSString *)sinceID 
                                 toId:(NSString *)toID 
                                state:(MTNotificationKind)notificationKind
{
    NSString *path = @"v1/my/notifications";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (offset > 0) {
        [params setValue:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    
    if (limit > 0) {
        [params setValue:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    
    if (sinceID && sinceID.length > 0) {
        [params setValue:sinceID forKey:@"since_id"];
    }
    
    if (toID && toID.length > 0) {
        [params setValue:toID forKey:@"to_id"];
    }
    
    switch (notificationKind) {
        case kMTNotificationAll:
        {
            [params setValue:@"all" forKey:@"state"];
        }
            break;
        case kMTNotificationRead:
        {
            [params setValue:@"read" forKey:@"state"];
        }       
            break;
        case kMTNotificationUnread:
        {
            [params setValue:@"unread" forKey:@"state"];
        }       
            break;
            
        default:
            break;
    }
    
    [self sendRequestWithMethod:nil 
                           path:path 
                queryParameters:params 
                    requestType:DGRequestNotifications 
                   responseType:DGResponseNotificationList];
    
}


#if DEBUG
- (void) getOut
{
    NSLog(@"GET OUT");
}
#endif

@end
