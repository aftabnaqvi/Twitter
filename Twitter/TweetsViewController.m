//
//  TweetsViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/19/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetViewController.h"
#import "ComposeTweetViewController.h"
#import "ProfileViewController.h"

#import "User.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "SVProgressHUD.h"


@interface TweetsViewController ()<UITableViewDataSource,
									UITableViewDelegate,
									TweetCellDelegate,
									TweetViewControllerDelegate,
									ComposeTweetViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshTweetsControl;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// set self as table view data source and delegate
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.estimatedRowHeight = 105;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// register tweet cell nib
	[self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
	
	[self setupNavigationbar];
	
	[self setupPullToRefresh];
	
	[self showSpinner];

	[self refreshTweets];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) setupNavigationbar{
	
	// add Sign Out button
	UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
	self.navigationItem.leftBarButtonItem = leftBarButton;
	
	// set title
	self.navigationItem.title = @"Home";

	// add New button icon
	UIImage *image = [[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
	
	self.navigationItem.rightBarButtonItem = rightBarButton;
	
	self.navigationController.navigationBar.barTintColor = RGB(85, 172, 238);
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	self.navigationController.navigationBar.translucent = NO;
}

-(void) showSpinner{
	[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
	[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
	[SVProgressHUD setBackgroundColor:RGB(85, 172, 238)];
}

-(void) setupPullToRefresh{
	// pull to refresh tweets. Network request...
	self.refreshTweetsControl = [[UIRefreshControl alloc] init];
	[self.tableView addSubview:self.refreshTweetsControl];
	[self.refreshTweetsControl addTarget:self action:@selector(refreshTweets) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTweets {
	[[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {

		if (tweets != nil) {
			self.tweets = tweets;
			[self.tableView reloadData];
		} else {
			NSLog(@"Error getting timeline, too many requests?: %@", error);
		}
		
		[SVProgressHUD dismiss];
		[self.refreshTweetsControl endRefreshing];
		[self.tableView setHidden:NO];
	}];
}

- (void)onLogout {
	[User logout];
}

#pragma mark tableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// unhighlight selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TweetViewController *vc = [[TweetViewController alloc] init];
	vc.delegate = self;
	vc.tweet = self.tweets[indexPath.row];
	[self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"%ld", self.tweets.count);
	return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
	tweetCell.tweet = self.tweets[indexPath.row];
	tweetCell.delegate = self;
	
	// fetch more tweets now.
	if (indexPath.row == self.tweets.count - 1) {
		[self fetchMoreTweets];
	}
	
	return tweetCell;
}

- (void)didTweet:(Tweet *)tweet {
	NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
	[temp insertObject:tweet atIndex:0];
	self.tweets = [temp copy];
	[self.tableView reloadData];
}

- (void)didTweetSuccessfully {
	// so a newly generated tweet can be replied or favorited
	[self.tableView reloadData];
}

#pragma mark TweetViewControllerDelegate methods

- (void)didReply:(Tweet *)tweet {
	// reloading the data... after tweet
	[self didTweet:tweet];
}

- (void)didRetweet:(BOOL)didRetweet {
	// reloading the data... after retweet
	[self.tableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
	[self.tableView reloadData];
}

- (void) fetchMoreTweets {
	NSString *maxIdString = [self.tweets[self.tweets.count - 1] idString];
	if (maxIdString == nil) {
		return;
	}
	
	// setting params
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"max_id"] = maxIdString;
	
	[[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
		if (tweets != nil && tweets.count > 0) {
			// ignore duplicate requests
			if ([[tweets[tweets.count - 1] idString] isEqualToString:[self.tweets[self.tweets.count - 1] idString]]) {
				NSLog(@"Ignoring duplicate data");
			} else {
				NSLog(@"%ld more tweets received", tweets.count);
				NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
				[temp addObjectsFromArray:tweets];
				self.tweets = [temp copy];
				[self.tableView reloadData];
			}
		} else {
			NSLog(@"No more tweets retrieved");
		}
		
		if(error){
			NSLog(@"Error: %@", error);
		}
	}];
}

- (void)onNew {
	[self composeTweet:nil];
}

#pragma mark TweetCell deleate
- (void)onReply:(TweetCell *)tweetCell {
	[self composeTweet:tweetCell];
}

-(void) onProfile:(User *)user{
	ProfileViewController *pvc = [[ProfileViewController alloc] init];
	[pvc setUser:user];
	[self.navigationController pushViewController:pvc animated:YES];
}

-(void) composeTweet:(TweetCell *)tweetCell{
	ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
	vc.delegate = self;
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	nvc.navigationBar.translucent = NO;
	if(tweetCell != nil){
		vc.reply = tweetCell.tweet;
	}
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}
@end
