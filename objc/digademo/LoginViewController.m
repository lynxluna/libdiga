//
//  LoginViewController.m
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import "DGBackend.h"
#import "LoginViewController.h"
#import "NXOAuth2.h"
#import "NSURL+NXOAuth2.h"
#import "NSDictionary+MindTalk.h"
#import "Globals.h"
#import "DGToken.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginButton;
@synthesize popularButton;
@synthesize atButton;
@synthesize atLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _backend = [[DGBackend alloc] initWithAPIDomain:@"api.mindtalk.com" 
                                             apiKey:API_KEY delegate:self];
    
    _tokenData = [[NSMutableData data] retain];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}



- (void)viewDidUnload
{
    [self setLoginButton:nil];
    [self setPopularButton:nil];
    [self setAtButton:nil];
    [self setAtLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
        [_token release];
    [loginButton release];
    [popularButton release];
    [atButton release];
    [atLabel release];
    [super dealloc];
}
- (IBAction)loginClicked:(id)sender {
     [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Bisikan Hati"];
}

- (IBAction)popularClicked:(id)sender {
    [self performSegueWithIdentifier:@"pushToStream" sender:self];
}

- (IBAction)gotoPost:(id)sender {
    [self performSegueWithIdentifier:@"modalPost" sender:self];
}

- (IBAction)getAccessToken:(id)sender {
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_code"];
    [_backend getAccessTokenFromCode:code];
}

- (void) tokenReceived:(DGToken *)token forRequestType:(DGRequestType)requestType
{
    [token saveToUserDefaults];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_tokenData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_tokenData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[_tokenData length]);
    
    // release the connection, and the data object
    [connection release];
    
    NSString *qs = [NSString stringWithUTF8String:[_tokenData bytes]];
    
    NSDictionary *tokenDict = [NSDictionary dictionaryFromQueryString:qs];
    
    _token = [[tokenDict objectForKey:@"access_token"] retain];
    
    [[NSUserDefaults standardUserDefaults] setObject:_token forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    atLabel.text = _token;
    
    [_tokenData release];
}
@end
