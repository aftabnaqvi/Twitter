//
//  ProfileViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ProfileViewController.h"
#import "ComposeTweetViewController.h"
#import "ProfileCell.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "TweetViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopConstraint;

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshTweetsControl;
@property (strong, nonatomic) SVProgressHUD *loadingIndicator;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	User *user = self.user ? self.user : [User currentUser];
	
	// add sign on button it is current user.
	if (!self.user) {
		// add Sign Out button
		UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
		self.navigationItem.leftBarButtonItem = leftBarButton;

	}
	
	self.navigationItem.title = user.name;
	
	// use banner url if provided, or profile bg url
	NSString *bannerUrl = user.bannerUrl ? [NSString stringWithFormat:@"%@/mobile_retina", user.bannerUrl] : user.backgroundImageUrl;
	[self.bgView setImageWithURL:[NSURL URLWithString:bannerUrl]];
	
	// add new tweet icon
	UIImage *image = [[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
	self.navigationItem.rightBarButtonItem = rightBarButton;
	
	// register profile cell
	[self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
	
	// register tweet cell
	[self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
	
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// show spinner
	[self showSpinner];
	
	if (user) {
		[self refreshProfile];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) showSpinner{
	[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
	[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
	[SVProgressHUD setBackgroundColor:RGB(85, 172, 238)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// unhighlight selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// do nothing if profile cell
	if (indexPath.row == 0) {
		return;
	}
	
	TweetViewController *vc = [[TweetViewController alloc] init];
	vc.delegate = self;
	vc.tweet = self.tweets[indexPath.row - 1];
	[self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tweets.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0 ) {
		self.tableView.rowHeight = 250;
		ProfileCell *profileCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
		profileCell.delegate = self;
		
		User *user;
		
		if (self.user) {
			user = self.user;
		} else {
			user = [User currentUser];
		}
		
		[profileCell setUser:user];
		
		return profileCell;
	} else {
		TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
		tweetCell.tweet = self.tweets[indexPath.row - 1];
		tweetCell.delegate = self;
		
		if([self.tweets[indexPath.row - 1] retweeted] == YES )
			self.tableView.rowHeight = 125;
		else
			self.tableView.rowHeight = 105;
		
		// check, if we need more tweets...
		if (indexPath.row == self.tweets.count - 1) {
			NSLog(@"End of list. fetch More...");
			[self fetchMoreTweets];
		}
		
		return tweetCell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row == 0)
		return 250;
	else if([self.tweets[indexPath.row - 1] retweeted] == YES )
		return 125;
	else
		return 105;
}


- (void)didTweet:(Tweet *)tweet {
	// only add if own tweet
	if (!self.user) {
		NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
		[temp insertObject:tweet atIndex:0];
		self.tweets = [temp copy];
		[self.tableView reloadData];
	}
}

- (void)didTweetSuccessfully {
	// so a newly generated tweet can be replied or favorited
	[self.tableView reloadData];
}

- (void)refreshProfile {
	[[TwitterClient sharedInstance] userTimelineWithParams:nil user:self.user completion:^(NSArray *tweets, NSError *error) {
		if (error) {
			NSLog(@"Error getting user timeline: %@", error);
		} else {
			self.tweets = tweets;
			[self.tableView reloadData];
		}
		[SVProgressHUD dismiss];
		[self.refreshTweetsControl endRefreshing];
		[self.bgView setHidden:NO];
		[self.tableView setHidden:NO];
	}];
}

- (void)onLogout {
	[User logout];
}

- (void)onNew {
	ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
	if (self.user && ![self.user.screenName isEqualToString:[[User currentUser] screenName]]) {
		vc.message = self.user;
	}
	
	vc.delegate = self;
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	nvc.navigationBar.translucent = NO;
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)didReply:(Tweet *)tweet {
	[self didTweet:tweet];
}

- (void)didRetweet:(BOOL)didRetweet {
	[self.tableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
	[self.tableView reloadData];
}

- (void) fetchMoreTweets {
	//NO max_id str available, don't do anything
	NSString *maxIdStr = [self.tweets[self.tweets.count - 1] idString];
	if (maxIdStr == nil) {
		return;
	}
	
	[[TwitterClient sharedInstance] userTimelineWithParams:@{ @"max_id": maxIdStr} user:self.user completion:^(NSArray *tweets, NSError *error) {

		if (error) {
			NSLog(@"Error getting more tweets: %@", error);
		} else if (tweets.count > 0) {
			// ignore duplicate requests
			if ([[tweets[tweets.count - 1] idString] isEqualToString:[self.tweets[self.tweets.count - 1] idString]]) {
				NSLog(@"Ignoring duplicates");
			} else {
				NSLog(@"%lu more tweets", (unsigned long)tweets.count);
				NSMutableArray *newTweets = [NSMutableArray arrayWithArray:self.tweets];
				[newTweets addObjectsFromArray:tweets];
				self.tweets = [newTweets copy];
				[self.tableView reloadData];
				[SVProgressHUD dismiss];
			}
		} else {
			NSLog(@"No more tweets got");
		}
	}];
}

- (void)onReply:(TweetCell *)tweetCell {
	ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
	vc.delegate = self;
	
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
	nvc.navigationBar.translucent = NO;
	// set reply to tweet property
	vc.reply = tweetCell.tweet;
	[self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)onProfile:(User *)user {
	// just shake the screen if for the same profile
	NSString *profileScreenName = self.user ? self.user.screenName : [[User currentUser] screenName];
	if ([user.screenName isEqualToString:profileScreenName]) {
		NSLog(@"Profile for user already displayed");
		// http://stackoverflow.com/questions/1632364/shake-visual-effect-on-iphone-not-shaking-the-device
		CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
		anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
		anim.autoreverses = YES ;
		anim.repeatCount = 2.0f ;
		anim.duration = 0.09f ;
		
		[self.view.layer addAnimation:anim forKey:nil];
		return;
	}
	ProfileViewController *pvc = [[ProfileViewController alloc] init];
	[pvc setUser:user];
	[self.navigationController pushViewController:pvc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat scrollOffset = scrollView.contentOffset.y;
	
	if (scrollOffset < 0) {
		self.bgImageHeightConstraint.constant = 80 - scrollOffset;
		self.bgImageTopConstraint.constant = 0;
	} else {
		self.bgImageHeightConstraint.constant = 80;
		self.bgImageTopConstraint.constant = - scrollOffset / 3;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)pageChanged:(UIPageControl *)pageControl {
	if (pageControl.currentPage == 0) {
		[UIView animateWithDuration:.24 animations:^{
			self.bgView.alpha = 1;
			self.bgImageHeightConstraint.constant = 80;
			[self.view layoutIfNeeded];
		}];
	} else {
		[UIView animateWithDuration:.24 animations:^{
			self.bgView.alpha = .5;
			self.bgImageHeightConstraint.constant = 100;
			[self.view layoutIfNeeded];
		}];
	}
}

@end
