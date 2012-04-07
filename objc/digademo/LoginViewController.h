//
//  LoginViewController.h
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGBackendDelegate.h"

@class DGBackend;
@interface LoginViewController : UIViewController<DGBackendDelegate>
{
    NSMutableData *_tokenData;
    NSString *_token;
    DGBackend *_backend;
}

@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIButton *popularButton;
@property (retain, nonatomic) IBOutlet UIButton *atButton;
@property (retain, nonatomic) IBOutlet UILabel *atLabel;

- (IBAction)loginClicked:(id)sender;
- (IBAction)popularClicked:(id)sender;
- (IBAction)gotoPost:(id)sender;
- (IBAction)getAccessToken:(id)sender;

@end
