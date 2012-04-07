//
//  PostViewController.h
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGBackendDelegate.h"

@class DGBackend;
@interface PostViewController : UIViewController<DGBackendDelegate>
{
    DGBackend *_backend;
    NSString *_origin;
}

@property (retain, nonatomic) IBOutlet UITextField *textPost;
@property (retain, nonatomic) IBOutlet UILabel *textDone;
- (IBAction)Post:(id)sender;
@end
