//
//  AppDelegate.m
//  digademo
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "NXOAuth2.h"
#import "NSString+MindTalk.h"
#import "NSDictionary+MindTalk.h"
#import "ChannelListViewController.h"
#import "Globals.h"

@implementation AppDelegate

@synthesize window = _window;

+ (void) initialize
{
    NSURL *authURL = [NSURL URLWithString:@"http://auth.mindtalk.com/authorize"];
    NSURL *tokenURL = [NSURL URLWithString:@"http://auth.mindtalk.com/access_token"];
    NSURL *redirectURL = [NSURL URLWithString:@"mindtalk://"];
    
    [[NXOAuth2AccountStore sharedStore] setClientID: CLIENT_ID
                                             secret: SECRET 
                                   authorizationURL: authURL
                                           tokenURL: tokenURL
                                        redirectURL: redirectURL 
                                     forAccountType: @"Bisikan Hati"];
}
     
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    if (!url) {  return NO; }
    
    NSString *qs = [url query];

    NSDictionary *dict = [NSDictionary dictionaryFromQueryString:qs];
    
    NSString *code = [dict objectForKey:@"code"];
    
    if (code) {
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"access_code"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
