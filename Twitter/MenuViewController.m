//
//  MenuViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MenuViewController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *accountsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYConstraint;

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *currentVC;

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
	
	// Timeline
	TweetsViewController *tvc = [[TweetsViewController alloc] init];
	UINavigationController *tnvc = [[UINavigationController alloc] initWithRootViewController:tvc];
	tnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
	tnvc.navigationBar.tintColor = [UIColor whiteColor];
	[tnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	tnvc.navigationBar.translucent = NO;
	
	self.currentVC = tnvc;
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

- (void)addAccount {
	NSLog(@"Add account");
}

- (void)removeCurrentViewController {
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

@end
