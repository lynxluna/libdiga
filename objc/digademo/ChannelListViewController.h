//
//  ChannelListViewController.h
//  diga
//
//  Created by Muhammad Noor on 06/04/12.
//  Copyright (c) 2012 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGBackendDelegate.h"

@class DGBackend;
@class DGHTTPConnection;
@interface ChannelListViewController : UITableViewController<DGBackendDelegate>
{
    DGBackend *_backend;
    NSDictionary *_userData;
    NSArray *_keys;
    
}

@end
