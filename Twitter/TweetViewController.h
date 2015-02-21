//
//  TweetViewController.h
//  Twitter
//
//  Created by Syed Naqvi on 2/20/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "Tweet.h"
//#import "ComposeViewController.h"

@protocol TweetViewControllerDelegate <NSObject>

- (void)didReply:(Tweet *)tweet;
- (void)didRetweet:(BOOL)didRetweet;
- (void)didFavorite:(BOOL)didFavorite;

@end

@interface TweetViewController : UIViewController 

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, weak) id <TweetViewControllerDelegate> delegate;

@end
