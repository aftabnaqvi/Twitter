//
//  TweetCell.h
//  Twitter
//
//  Created by Syed Naqvi on 2/19/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)onReply:(TweetCell *)tweetCell;
- (void)onProfile:(User *)user;

@end

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, weak) id <TweetCellDelegate> delegate;

@end