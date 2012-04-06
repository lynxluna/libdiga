//
//  PostViewController.h
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DGBackend;
@interface PostViewController : UIViewController
{
    DGBackend *_backend;
}

@property (retain, nonatomic) IBOutlet UITextField *textPost;
@property (retain, nonatomic) IBOutlet UILabel *textDone;
- (IBAction)Post:(id)sender;
@end
