//
//  MenuViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "TweetsViewController.h"
#import "MentionsViewController.h"
#import "TwitterClient.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYConstraint;

@property (strong, nonatomic) NSArray *viewControllerItems;
@property (strong, nonatomic) UIViewController *currentVC;

@end

@implementation MenuViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	// set Twitter background color
	self.view.backgroundColor = RGB(85, 172, 238);
	
	self.contentViewXConstraint.constant = 0;
	
	// delegates
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	[self createViewControllers];
	[self.tableView reloadData];
}

- (void)createViewControllers {
	
	// Profile View
	ProfileViewController *pvc = [[ProfileViewController alloc] init];
	UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
	pnvc.navigationBar.barTintColor = RGB(85, 172, 238);
	pnvc.navigationBar.tintColor = [UIColor whiteColor];
	[pnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	pnvc.navigationBar.translucent = NO;
	
	// Timeline
	TweetsViewController *tvc = [[TweetsViewController alloc] init];
	UINavigationController *tnvc = [[UINavigationController alloc] initWithRootViewController:tvc];
	tnvc.navigationBar.barTintColor = RGB(85, 172, 238);
	tnvc.navigationBar.tintColor = [UIColor whiteColor];
	[tnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	tnvc.navigationBar.translucent = NO;
	
	// Mentions
	MentionsViewController *mvc = [[MentionsViewController alloc] init];
	UINavigationController *mnvc = [[UINavigationController alloc] initWithRootViewController:mvc];
	mnvc.navigationBar.barTintColor = RGB(85, 172, 238);
	mnvc.navigationBar.tintColor = [UIColor whiteColor];
	[mnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	mnvc.navigationBar.translucent = NO;
	
	self.viewControllerItems = [NSArray arrayWithObjects:pnvc, tnvc, mnvc, nil];

	// set ProfileViewController as initial view
	self.currentVC = pnvc;
	self.currentVC.view.frame = self.contentView.bounds;
	[self.contentView addSubview:self.currentVC.view];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row < 3) {
		self.currentVC = self.viewControllerItems[indexPath.row];
		[self setContentController];
	} else {
		NSLog(@"Error: Invalid selection.");
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3; // currently we have 3 items in the menu.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;
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
	}
	
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.backgroundColor = RGB(85, 172, 238);
	
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

- (void)setContentController {
	self.currentVC.view.frame = self.contentView.bounds;
	[self.contentView addSubview:self.currentVC.view];
	[self.currentVC didMoveToParentViewController:self];
	
	
	[UIView animateWithDuration:1.0 animations:^{
		self.contentViewXConstraint.constant = 0;
		[self.view layoutIfNeeded];
	}];
}

@end
