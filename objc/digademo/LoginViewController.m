//
//  LoginViewController.m
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import "LoginViewController.h"
#import "NXOAuth2.h"
#import "NSURL+NXOAuth2.h"
#import "NSDictionary+MindTalk.h"

#define SECRET @"YOUR_APPLICATION_SECRETgi"

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

- (IBAction)atClicked:(id)sender {
    
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_code"];
    NSString *urlStr = [NSString stringWithFormat:@"http://auth.mindtalk.com/access_token?code=%@&client_secret=%@",
                        code, SECRET];
    if (code) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [NSURLConnection connectionWithRequest:req delegate:self];
    }
}

- (IBAction)gotoPost:(id)sender {
    [self performSegueWithIdentifier:@"modalPost" sender:self];
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
