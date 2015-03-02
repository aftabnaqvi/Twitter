//
//  AppDelegate.m
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TwitterClient.h"
#import "User.h"

#import "TweetsViewController.h"
#import "MenuViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	 self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:UserLogoutNotification object:nil];
	User *user = [User currentUser];
	if (user != nil) {
		NSLog(@"Welcome %@", user.name);
		
		UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:[[MenuViewController alloc] init]];
		
		pnvc.navigationBar.barTintColor =  RGB(85, 172, 238);
		pnvc.navigationBar.tintColor = [UIColor whiteColor];
		[pnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
		pnvc.navigationBar.translucent = NO;
		self.window.rootViewController = pnvc;
		
		
		
	} else {
		NSLog(@"Not logged in");
		self.window.rootViewController = [[LoginViewController alloc] init];
	}
	
	[self.window makeKeyAndVisible];
	
	// update status bar appearance
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	
}

// When ever our receives this call, it gives us oppertunity to handle the callback and do some action.
-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
	[[TwitterClient sharedInstance] openURL:url];
	
	return YES;
}

- (void)userLogout {
	if (User.accounts.count > 0) {
	} else {
		NSLog(@"Showing login screen after logout");
		self.window.rootViewController = [[LoginViewController alloc] init];
	}
}
@end

/*
	// This callback invokes whenever someone calls your using the URL scheme. You can handle it here...
	// Access token URL	"https://api.twitter.com/oauth/access_token" is the last end point we need to call.
	//
	
	[[TwitterClient sharedInstance] fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]
	
	success:^(BDBOAuth1Credential* accessToken) {
 NSLog(@"Got the access token");
 [[TwitterClient sharedInstance].requestSerializer saveAccessToken:accessToken]; // saving the access token.
	
 // gettingt the User.
 [[TwitterClient sharedInstance] GET:@"1.1/account/verify_credentials.json" parameters:nil
 success:^(AFHTTPRequestOperation *operstion, id responseObject ){
 //NSLog(@"%@ current User: ", responseObject);
 User* user = [[User alloc] initWithDictionary:responseObject];
 NSLog(@"current Username: %@", user.name);
 
 }failure:^(AFHTTPRequestOperation *operation, NSError* error){
 NSLog(@"Failed to get current User....");
 }];
 
 // now get the timeline.
 [[TwitterClient sharedInstance] GET:@"1.1/statuses/home_timeline.json" parameters:nil
 success:^(AFHTTPRequestOperation *operstion, id responseObject ){
 
 NSArray* tweets = [Tweet tweetsWithArray:responseObject];
 for(Tweet *tweet in tweets){
 NSLog(@"tweet: %@, createdAt: %@", tweet.text, tweet.createdAt);
 }
 
 }failure:^(AFHTTPRequestOperation *operation, NSError* error){
 NSLog(@"Failed to get Tweets ....");
 }];
	}
	failure:^(NSError *error){
 NSLog(@"Failed to get the access token");
	}];
 
 */
