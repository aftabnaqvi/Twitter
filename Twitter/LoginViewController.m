//
//  LoginViewController.m
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "LoginViewController.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"

#import "TwitterClient.h"


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwitterLogo;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTwitterLogin:(id)sender {
	// animate the logo
	[UIView animateWithDuration:.75 animations:^{
		self.imageViewTwitterLogo.transform = CGAffineTransformMakeScale(24, 24);
		self.view.backgroundColor = [UIColor whiteColor];
	}];
	[[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
		// bring the logo back
		self.imageViewTwitterLogo.transform = CGAffineTransformMakeScale(1, 1);

		if (user != nil) {
			// Modally present tweets view
			NSLog(@"Welcome to %@", user.name);
			MenuViewController *vc = [[MenuViewController alloc] init];
			[self presentViewController:vc animated:YES completion:nil];
		} else {
			// Present error view
			NSLog(@"Login error");
		}
	}];
}
@end


// Original code..
//[[TwitterClient sharedInstance].requestSerializer removeAccessToken];
//	// Step - 1
//	[[TwitterClient sharedInstance] fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil
//	  success:^(BDBOAuth1Credential *request_token){
//		  
//		  //Step - 2
//		  // FB has its own protocol. instagram has its owen protocol...
//		  // end point. this is a mobile app URL, which runs on the safari on iOS.
//		  NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", request_token.token]];
//		  
//		  // iOS uses openURL to communicate with the app.
//		  [[UIApplication sharedApplication] openURL:authUrl];
//		  
//		  // Now set the URI type in project settings. "cptwitterdemo" Just the scheme is required. No need for : and other stuff. Now run the app and you we will our app verifies that it know the scheme/url and no error you will see.
//		  
//		  // Till this point our app doesn't know how to handle this incoming request from safari. We need to write code in AppDelegate to get the Access token.
//		  
//		  NSLog(@"Got the request token");
//	  }failure:^(NSError *error){
//		  NSLog(@"Failed to get the request token");
//	  }];
//}