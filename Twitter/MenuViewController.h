//
//  MenuViewController.h
//  Twitter
//
//  Created by Syed Naqvi on 2/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
//#import "AccountsViewController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ProfileViewControllerDelegate>

//, ProfileViewControllerDelegate, AccountsViewControllerDelegate>

- (void)showAccountViewController;

@end