//
//  MenuViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MenuViewController.h"
//#import "ProfileViewController.h"
#import "TweetsViewController.h"
//#import "MentionsViewController.h"
//#import "AccountsViewController.h"
#import "TwitterClient.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *accountsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYConstraint;

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *currentVC;
//@property (strong, nonatomic) AccountsViewController *avc;

@end

@implementation MenuViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	// set bg color
	self.view.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
	
	// reset constraint
	self.contentViewXConstraint.constant = 0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	[self initViewControllers];
	[self.tableView reloadData];
}

- (void)initViewControllers {
	
	// Profile View
	ProfileViewController *pvc = [[ProfileViewController alloc] init];
	UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
	pnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
	pnvc.navigationBar.tintColor = [UIColor whiteColor];
	[pnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	pnvc.navigationBar.translucent = NO;
	// set self as delage for pull downs
	pvc.delegate = self;
	
	// Timeline
	TweetsViewController *tvc = [[TweetsViewController alloc] init];
	UINavigationController *tnvc = [[UINavigationController alloc] initWithRootViewController:tvc];
	tnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
	tnvc.navigationBar.tintColor = [UIColor whiteColor];
	[tnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	tnvc.navigationBar.translucent = NO;
	
	//	// Mentions
	//	MentionsViewController *mvc = [[MentionsViewController alloc] init];
	//	UINavigationController *mnvc = [[UINavigationController alloc] initWithRootViewController:mvc];
	//	mnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
	//	mnvc.navigationBar.tintColor = [UIColor whiteColor];
	//	[mnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	//	mnvc.navigationBar.translucent = NO;
	//
	self.viewControllers = [NSArray arrayWithObjects:pnvc, tnvc, nil];
	//
	//	// set profile as initial view
	self.currentVC = tvc;
	self.currentVC.view.frame = self.contentView.bounds;
	[self.contentView addSubview:self.currentVC.view];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row < 3) {
		// add new
		[self removeCurrentViewController];
		self.currentVC = self.viewControllers[indexPath.row];
		[self setContentController];
	} else {
		[self showAccountViewController];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] init];
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Profile";
			break;
		case 1:
			cell.textLabel.text = @"Timeline";
			break;
		case 2:
			cell.textLabel.text = @"Mentions";
			break;
		case 3:
			cell.textLabel.text = @"Accounts";
			break;
	}
	
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.backgroundColor = RGB(85, 172, 238);//[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
	
	return cell;
}

// This removes the extra separators in TableView and adds empty footer
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return [UIView new];
}

#pragma mark swipes
- (IBAction)didSwipeRight:(id)sender {
	NSLog(@"Right swipe");
	// reload data to handle height change since row heights are based on table height
	[UIView animateWithDuration:1 animations:^{
		self.contentViewXConstraint.constant = -self.view.frame.size.width + 75;
		[self.view layoutIfNeeded];
	}];
}

- (IBAction)didSwipeLeft:(id)sender {
	NSLog(@"Left swipe");
	[UIView animateWithDuration:1 animations:^{
		self.contentViewXConstraint.constant = 0;
		[self.view layoutIfNeeded];
	}];
}

- (void)onPullForAccounts {
	[self showAccountViewController];
}

- (void)setAccount {
	NSLog(@"Set account");
	
	// remove old
	[self removeCurrentViewController];
	
	// reinit view controllers
	[self initViewControllers];
	
	[self.currentVC didMoveToParentViewController:self];
	
	[UIView animateWithDuration:.24 animations:^{
		self.contentViewXConstraint.constant = 0;
		self.contentViewYConstraint.constant = 0;
		[self.view layoutIfNeeded];
	}];
}

- (void)switchAccount:(User *)user {
	// if account is the same, then just return
	if ([user.screenName isEqualToString:User.currentUser.screenName]) {
		[self showProfileViewController];
		return;
	}
	
	NSLog(@"Switch account");
	[[TwitterClient sharedInstance] loginForUser:user completion:^(User *user, NSError *error) {
		if (user != nil) {
			[self removeCurrentViewController];
			User.currentUser = user;
			[self setAccount];
		} else {
			// Present error view
			NSLog(@"Login error");
		}
	}];
}

- (void)addAccount {
	NSLog(@"Add account");
	
	//	[[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
	//		if (user != nil) {
	//			[self.avc updateAccounts];
	//			[self removeCurrentViewController];
	//			User.currentUser = user;
	//			[self setAccount];
	//		} else {
	//			// Present error view
	//			NSLog(@"Login error");
	//		}
	//	}];
}

- (void)removeCurrentViewController {
	//    [self.currentVC willMoveToParentViewController:nil];
	//    [self.currentVC.view removeFromSuperview];
	//    [self.currentVC removeFromParentViewController];
}

- (void)setContentController {
	self.currentVC.view.frame = self.contentView.bounds;
	[self.contentView addSubview:self.currentVC.view];
	[self.currentVC didMoveToParentViewController:self];
	
	[UIView animateWithDuration:.24 animations:^{
		self.contentViewXConstraint.constant = 0;
		self.contentViewYConstraint.constant = 0;
		[self.view layoutIfNeeded];
	}];
}

- (void)setAccountController {
	self.currentVC.view.frame = self.accountsView.bounds;
	[self.accountsView addSubview:self.currentVC.view];
	[self.currentVC didMoveToParentViewController:self];
	
	[UIView animateWithDuration:.24 animations:^{
		self.contentViewXConstraint.constant = 0;
		self.contentViewYConstraint.constant = -self.contentView.bounds.size.height;
		[self.view layoutIfNeeded];
	}];
}

- (void)showAccountViewController {
	//	[self removeCurrentViewController];
	//	if (!self.avc) {
	//		self.avc = [[AccountsViewController alloc] init];
	//		self.avc.delegate = self;
	//	} else {
	//		[self.avc updateAccounts];
	//	}
	//	self.currentVC = self.avc;
	//	[self setAccountController];
}

- (void)showProfileViewController {
	[self removeCurrentViewController];
	self.currentVC = self.viewControllers[0];
	[self setContentController];
}

@end
