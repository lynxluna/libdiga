//
//  PostViewController.m
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import "DGBackend.h"
#import "PostViewController.h"

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
        _backend = [[DGBackend alloc] initWithAPIDomain:@"api.mindtalk.com" apiKey:@"YOUR_API_KEY" delegate:self];
        
    }
    
    _backend.accessToken = @"YOUR_ACCESS_TOKEN";
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTextPost:nil];
    [self setTextDone:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    [textPost release];
    [textDone release];
    [super dealloc];
}
- (IBAction)Post:(id)sender {
    if (textPost.text.length > 0) {
        textDone.text = @"Posting...";
        [_backend postMindWithMessage:textPost.text 
                            origin_id:@"YOUR_USER_ID"];
    }
}
@end
