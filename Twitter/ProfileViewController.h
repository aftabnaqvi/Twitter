//
//  ProfileViewController.h
//  Twitter
//
//  Created by Syed Naqvi on 2/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetCell.h"
#import "ProfileCell.h"
#import "TweetViewController.h"
#import "ComposeTweetViewController.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource,
													UITableViewDelegate,
													ComposeTweetViewControllerDelegate,
													TweetCellDelegate,
													TweetViewControllerDelegate,
													ProfileCellDelegate>

@property (strong, nonatomic) User *user;

@end

