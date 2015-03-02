//
//  MentionsViewController.h
//  Twitter
//
//  Created by Syed Naqvi on 2/28/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTweetViewController.h"
#import "TweetViewController.h"
#import "TweetCell.h"

@interface MentionsViewController : UIViewController <UITableViewDataSource,
									UITableViewDelegate,
									ComposeTweetViewControllerDelegate,
									TweetViewControllerDelegate,
									TweetCellDelegate>

@property (strong, nonatomic) User *user;

@end
