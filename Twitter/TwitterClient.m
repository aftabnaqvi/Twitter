//
//  TwitterClient.m
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"

NSString * const kTwitterCosumerKey = @"umPp4SbN4HSqIF2ye0dXZ8ujo";
NSString * const kTwitterCosumerSecret = @"K5QTlxx0O8mZFs8BY2km1U7TxkssFPDLmHtt8UwzRMoCymDbjD";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient ()
@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@end

@implementation TwitterClient
+(TwitterClient *) sharedInstance{
	static TwitterClient *instance = nil;
	
	// grand centeral dispatch which makes sure it will execute once.
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(instance == nil){
			instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterCosumerKey consumerSecret:kTwitterCosumerSecret];
		}
	});

	return instance;
}

-(void)loginWithCompletion:(void (^)(User *user, NSError *error))completion{
	self.loginCompletion = completion;
	
	[self.requestSerializer removeAccessToken];
	
	// Step - 1
	[self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil
	  success:^(BDBOAuth1Credential *request_token){
		  
		  //Step - 2
		  // FB has its own protocol. instagram has its owen protocol...
		  // end point. this is a mobile app URL, which runs on the safari on iOS.
		  NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", request_token.token]];
		  
		  // iOS uses openURL to communicate with the app.
		  [[UIApplication sharedApplication] openURL:authUrl];
		  
		  // Now set the URI type in project settings. "cptwitterdemo" Just the scheme is required. No need for : and other stuff. Now run the app and you we will our app verifies that it know the scheme/url and no error you will see.
		  
		  // Till this point our app doesn't know how to handle this incoming request from safari. We need to write code in AppDelegate to get the Access token.
		  
		  NSLog(@"Got the request token");
	  }failure:^(NSError *error){
		  NSLog(@"Failed to get the request token");
		  self.loginCompletion(nil, error);
	  }];
}

-(void) openURL:(NSURL *)url{
	// This callback invokes whenever someone calls your using the URL scheme. You can handle it here...
	// Access token URL	"https://api.twitter.com/oauth/access_token" is the last end point we need to call.
	//
	
	[self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]
	 
	 success:^(BDBOAuth1Credential* accessToken) {
		NSLog(@"Got the access token");
		[self.requestSerializer saveAccessToken:accessToken]; // saving the access token.
		 
		 // gettingt the User.
		[self GET:@"1.1/account/verify_credentials.json" parameters:nil
			 success:^(AFHTTPRequestOperation *operstion, id responseObject ){
				 User *user = [[User alloc] initWithDictionary:responseObject];
				 [User setCurrentUser:user];
				 
				 NSLog(@"current Username: %@", user.name);
				 self.loginCompletion(user, nil);
			 }failure:^(AFHTTPRequestOperation *operation, NSError* error){
				 NSLog(@"Failed to get current User....");
				 self.loginCompletion(nil, error);
			 }];
		}
	 failure:^(NSError *error){
		 NSLog(@"Failed to get the access token");
	 }];

}

- (void)loginForUser:(User *)user completion:(void (^)(User *, NSError *))completion {
	self.loginCompletion = completion;
	
	[self.requestSerializer removeAccessToken];
	[self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
		NSLog(@"got the request token!");
		
		NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?force_login=1&oauth_token=%@&screen_name=%@", requestToken.token, user.screenName]];
		[[UIApplication sharedApplication] openURL:authURL];
		
	} failure:^(NSError *error) {
		NSLog(@"Failed to get the request token!");
		self.loginCompletion(nil, error);
	}];
}

- (void)userTimelineWithParams:(NSDictionary *)params user:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion {
	User *forUser = user ? user : [User currentUser];
	NSString *getUrl = [NSString stringWithFormat:@"1.1/statuses/user_timeline.json?include_rts=1&count=20&include_my_retweet=1&screen_name=%@", forUser.screenName];
	[self GET:getUrl parameters:params
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSArray *tweets = [Tweet tweetsWithArray:responseObject];
			completion(tweets, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			completion(nil, error);
	}];
}

- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
	[self GET:@"1.1/statuses/mentions_timeline.json?include_my_retweet=1" parameters:params
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSArray *tweets = [Tweet tweetsWithArray:responseObject];
			completion(tweets, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			completion(nil, error);
	}];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
	[self GET:@"1.1/statuses/home_timeline.json?include_my_retweet=1" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSArray *tweets = [Tweet tweetsWithArray:responseObject];
		completion(tweets, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(nil, error);
	}];
}

- (void)postTweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion {
	NSString *postUrl;
	
	if (tweet.replyToIdString) {
		postUrl = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@&in_reply_to_status_id=%@", tweet.text, tweet.replyToIdString];
	} else {
		postUrl = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@", tweet.text];
	}
	
	[self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params
	   success:^(AFHTTPRequestOperation *operation, id responseObject) {
			completion(responseObject[@"id_str"], nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			completion(nil, error);
	}];
}

- (void)postRetweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion {
	NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idString];
	
	[self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params
	   success:^(AFHTTPRequestOperation *operation, id responseObject) {
		   completion(responseObject[@"id_str"], nil);
	   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		   completion(nil, error);
	}];
}

- (void)postUnretweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
	NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweet.retweetIdString];
	
	[self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		completion(nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(error);
	}];
}

- (void)postFavoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
	NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/create.json?id=%@", tweet.idString];
	
	[self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		completion(nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(error);
	}];
}

- (void)postUnfavoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
	NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/destroy.json?id=%@", tweet.idString];
	
	[self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		completion(nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(error);
	}];
}

@end
