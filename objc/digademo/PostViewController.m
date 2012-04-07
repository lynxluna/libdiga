//
//  PostViewController.m
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import "DGBackend.h"
#import "PostViewController.h"
#import "Globals.h"
#import "DGToken.h"

@interface PostViewController ()

@end

@implementation PostViewController
@synthesize textPost;
@synthesize textDone;

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
    [super viewDidLoad];
    
    if (!_backend) {
        _backend = [[DGBackend alloc] initWithAPIDomain:@"api.mindtalk.com" 
                                                 apiKey:API_KEY delegate:self];
        
    }
    
    DGToken *tok = [DGToken tokenFromUserDefaults];
    
    _backend.accessToken = tok ? tok.accessToken : DEV_ACCESS_TOKEN;
    
	[_backend getMyInfo];
    
    textPost.enabled = NO;
    textPost.text    = @"Getting User Origin...";
}

- (void)viewDidUnload
{
    [self setTextPost:nil];
    [self setTextDone:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) userListReceived:(NSArray *)users forRequestType:(DGRequestType)requestType
{
    NSDictionary *userData = [users objectAtIndex:0];
    [_origin release];
    _origin = [[userData objectForKey:@"id"] retain];
    textPost.text = @"";
    textPost.enabled = YES;
    
}

- (void) onGenericResultReceived: (NSArray*) statuses forRequestType: (DGRequestType) requestType
{
    textDone.text = @"Posted!";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_origin release];
    [textPost release];
    [textDone release];
    [super dealloc];
}
- (IBAction)Post:(id)sender {
    if (textPost.text.length > 0) {
        textDone.text = @"Posting...";
        [_backend postMindWithMessage:textPost.text 
                            origin_id:_origin];
    }
}
@end
