//
//  TweetViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/20/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "TweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"
#import "ComposeTweetViewController.h"

@interface TweetViewController () <ComposeTweetViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImageView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topProfileImageConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNameConstraint;

@end

@implementation TweetViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	// set title
	self.navigationItem.title = @"Tweet";
	
	[self setupView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) setupView{
	// add New button icon
	UIImage *image = [[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onReply)];
	
	self.navigationItem.rightBarButtonItem = rightBarButton;
	
	if (self.tweet) {
		User *user = self.tweet.user;
		Tweet *tweetToDisplay;
		
		if (self.tweet.retweetedTweet != nil) {
			tweetToDisplay = self.tweet.retweetedTweet;
			self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted", user.name];
			[self.retweetImageView setHidden:NO];
			[self.retweetedByLabel setHidden:NO];
			// update constraints dynamically
			self.topProfileImageConstraint.constant = 20;
			self.topNameConstraint.constant = 20;
		} else {
			tweetToDisplay = self.tweet;
			[self.retweetImageView setHidden:YES];
			[self.retweetedByLabel setHidden:YES];
			self.topProfileImageConstraint.constant = 10;
			self.topNameConstraint.constant = 10;
		}
		
		// rounded corners for profile images
		CALayer *layer = [self.profileImageView layer];
		[layer setMasksToBounds:YES];
		[layer setCornerRadius:3.0];
		[self.profileImageView setImageWithURL:[NSURL URLWithString:tweetToDisplay.user.profileImageUrl]];
		
		self.nameLabel.text = tweetToDisplay.user.name;
		self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweetToDisplay.user.screenName];
		self.tweetLabel.text = tweetToDisplay.text;
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"M/d/yy, h:mm a"];
		self.timestampLabel.text = [dateFormat stringFromDate:tweetToDisplay.createdAt];
		self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetCount];
		self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToDisplay.favoriteCount];
		
		// set action button highlight states
		[self highlightButton:self.retweetButton highlight:self.tweet.retweeted];
		[self highlightButton:self.favoriteButton highlight:self.tweet.favorited];
		
		// if this tweet has no id, then disable all actions
		if (self.tweet.idString == nil) {
			rightBarButton.enabled = NO;
			self.retweetButton.enabled = NO;
			self.replyButton.enabled = NO;
			self.favoriteButton.enabled = NO;
		}
		
		// if this is the user's own tweet, disable retweet
		if (self.tweet.retweetedTweet != nil &&
			[[[User currentUser] screenName] isEqualToString:user.screenName]) {
			self.retweetButton.enabled = NO;
		}
	}
}

- (void)onReply {
	ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
	vc.delegate = self;
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	nvc.navigationBar.translucent = NO;
	
	// set reply to tweet property
	vc.reply = self.tweet;
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)setTweet:(Tweet *)tweet {
	_tweet = tweet;
}

- (IBAction)onReply:(id)sender {
	[self onReply];
}

- (IBAction)onRetweet:(id)sender {
	[self.tweet retweet];
	self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetCount];
	[self highlightButton:self.retweetButton highlight:self.tweet.retweeted];
	[self.delegate didRetweet:self.tweet.retweeted];
}

- (IBAction)onFavorite:(id)sender {
	// favorite the original tweet if applicable
	Tweet *tweetToFavorite;
	if (self.tweet.retweetedTweet) {
		tweetToFavorite = self.tweet.retweetedTweet;
	} else {
		tweetToFavorite = self.tweet;
	}
	
	BOOL favorited = [tweetToFavorite favorite];
	
	// favorite/unfavorite the source
	if (self.tweet.retweetedTweet) {
		self.tweet.favorited = favorited;
	}
	
	self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToFavorite.favoriteCount];
	[self highlightButton:self.favoriteButton highlight:favorited];
	[self.delegate didFavorite:favorited];
}

- (void)highlightButton:(UIButton *)button highlight:(BOOL)highlight {
	if (highlight) {
		[button setSelected:YES];
	} else {
		[button setSelected:NO];
	}
}

#pragma mark <ComposeTweetViewControllerDelegate>

- (void)didTweet:(Tweet *)tweet{
	NSLog(@"didTweet successfully.");
}

- (void)didTweetSuccessfully{
	NSLog(@"didTweetSuccessfully");
	
}
@end

