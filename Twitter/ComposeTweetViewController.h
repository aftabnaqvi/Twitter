//
//  ComposeTweetViewController.h
//  Twitter
//
//  Created by Syed Naqvi on 2/21/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeTweetViewControllerDelegate <NSObject>

- (void)didTweet:(Tweet *)tweet;
- (void)didTweetSuccessfully;

@end

@interface ComposeTweetViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet; // reply
@property (nonatomic, strong) User *user; // message 
@property (nonatomic, weak) id <ComposeTweetViewControllerDelegate> delegate;

@end

