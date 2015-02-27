//
//  ComposeTweetViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/21/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "TwitterClient.h"
#import "TweetCell.h"

@interface ComposeTweetViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView	*profileImageView;
@property (weak, nonatomic) IBOutlet UITextView		*tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel		*nameLabel;
@property (weak, nonatomic) IBOutlet UILabel		*screenNameLabel;

@end

@implementation ComposeTweetViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tweetTextView.delegate = self;
	
	[self setupNavigationBar];
	
	User *currentUser = [User currentUser];

	// rounded corners
	CALayer *layer = [self.profileImageView layer];
	[layer setMasksToBounds:YES];
	[layer setCornerRadius:3.0];
	
	// setting data
	[self.profileImageView setImageWithURL:[NSURL URLWithString:[currentUser profileImageUrl]]];
	self.nameLabel.text = currentUser.name;
	self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
	
	
	// set initial reply to string if a reply
	if (self.reply) {
		// if replying to a retweet, mention original tweet author and retweeter
		if (self.reply.retweetedTweet) {
			if ([self.reply.user.screenName isEqualToString:[[User currentUser] screenName]]) {
				self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.reply.retweetedTweet.user.screenName];
			} else {
				self.tweetTextView.text = [NSString stringWithFormat:@"@%@ @%@ ", self.reply.retweetedTweet.user.screenName, self.reply.user.screenName];
			}
		} else {
			self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.reply.user.screenName];
		}
	}
	
	if (self.message) {
		self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.message.screenName];
	}
	
	// initialize character count
	[self textViewDidChange:self.tweetTextView];
	
	// start with focus on the text view
	[self.tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

	UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onCancel)];
	self.navigationItem.leftBarButtonItem = leftBarButton;

	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
	self.navigationItem.rightBarButtonItem = rightBarButton;
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
	
	
	self.navigationController.navigationBar.barTintColor = RGB(85, 172, 238);
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	self.navigationController.navigationBar.translucent = NO;
}

- (void)onCancel {
	// update status bar appearance
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTweet {
	Tweet *tweet = [[Tweet alloc] initWithText:self.tweetTextView.text replyToTweet:self.reply];
	
	[[TwitterClient sharedInstance] postTweetWithParams:nil tweet:tweet completion:^(NSString *tweetIdString, NSError *error) {
		if(tweetIdString != nil) {
			// set tweet id so it can be favorited
			NSLog(@"Tweet successful, tweet id_str: %@", tweetIdString);
			tweet.idString = tweetIdString;
			if ([self.delegate respondsToSelector:@selector(didTweetSuccessfully)]) {
				[self.delegate didTweetSuccessfully];

			} else {
				NSLog(@"Error posting tweet: %@", tweet);
			}
		}
	}];
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[self.delegate didTweet:tweet];
}

#pragma mark <UITextViewDelegate>
// keeps track of character count while typing the tweet.
- (void) textViewDidChange:(UITextView *)textView {
	long charsLeft = 140 - textView.text.length;
	
	// if negative count, set to red
	UIColor *titleColor = nil;
	if (charsLeft < 0) {
		titleColor = [UIColor redColor];
	} else {
		titleColor = [UIColor blackColor];
	}
	
	if (charsLeft < 0 || charsLeft == 140) {
		// disable tweet button
		self.navigationItem.rightBarButtonItem.enabled = NO;
	} else {
		// enable tweet button
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	
	UILabel *charsRemaningTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
	charsRemaningTitle.textAlignment = NSTextAlignmentRight;
	charsRemaningTitle.text = [NSString stringWithFormat:@"%ld", charsLeft];
	charsRemaningTitle.textColor = titleColor;
	[charsRemaningTitle setFont: [UIFont fontWithName:@"Helvetica Neue" size:15.0]];
	self.navigationItem.titleView = charsRemaningTitle;
}
@end
