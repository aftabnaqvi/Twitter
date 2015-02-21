//
//  Tweet.m
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "Tweet.h"

#import "TwitterClient.h"

@implementation Tweet

- (id) initWithDictionary:(NSDictionary *)dictionary  {
	self = [super init];
	if (self) {
		self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
		self.text = dictionary[@"text"];
		
		NSString *createdAtString = dictionary[@"created_at"];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
		
		self.createdAt = [formatter dateFromString:createdAtString];
		
		self.retweetCount = [dictionary[@"retweet_count"] integerValue];
		self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
		
		self.retweeted = [dictionary[@"retweeted"] boolValue];
		self.favorited = [dictionary[@"favorited"] boolValue];
		
		self.idString = dictionary[@"id_str"];
		
		if (dictionary[@"in_reply_to_status_id_str"]) {
			self.replyToIdString = dictionary[@"in_reply_to_status_id_str"];
		}
		
		if (dictionary[@"current_user_retweet"]) {
			self.retweetIdString = dictionary[@"current_user_retweet"][@"id_str"];
		} else if (self.retweeted && [self.user.screenName isEqualToString:[[User currentUser] screenName]]) {
			self.retweetIdString = self.idString;
		}
		
		if (dictionary[@"retweeted_status"]) {
			self.retweetedTweet = [[Tweet alloc] initWithDictionary:dictionary[@"retweeted_status"]];
		}
	}
	return self;
}

- (id) initWithText:(NSString *)text replyToTweet:(Tweet *)replyToTweet {
	NSDate *now = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
	
	NSDictionary *data = [NSDictionary dictionary];
	NSDictionary *user = [NSDictionary dictionary];
	User *currentUser = [User currentUser];
	
	user = @{
			 @"name" : currentUser.name,
			 @"screen_name" : currentUser.screenName,
			 @"profile_image_url" : currentUser.profileImageUrl,
			 @"description" : currentUser.tagLine
			 };
	
	data = @{
			 @"user" : user,
			 @"text" : text,
			 @"created_at" : [formatter stringFromDate:now],
			 @"retweeted" : @NO,
			 @"favorited" : @NO,
			 @"in_reply_to_status_id_str" : replyToTweet ? replyToTweet.idString : @NO
			 };
	
	return [self initWithDictionary:data];
}


+ (NSArray *)tweetsWithArray:(NSArray *)array {
	NSMutableArray *tweets = [NSMutableArray array];
	
	for (NSDictionary *dictionary in array) {
		[tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
	}
	
	return tweets;
}

- (BOOL)retweet {
	self.retweeted = !self.retweeted;
	if (self.retweeted) {
		self.retweetCount++;
		// retweet
		[[TwitterClient sharedInstance] postRetweetWithParams:nil tweet:self completion:^(NSString *retweetIdStr, NSError *error) {
			if (error) {
				NSLog(@"Retweet failed");
			} else {
				NSLog(@"Retweet successful, retweet_id_str: %@", retweetIdStr);
				// set retweet id string so it can be unretweeted
				self.retweetIdString = self.retweetIdString;
			}
		}];
	} else {
		self.retweetCount--;
		// unretweet
		[[TwitterClient sharedInstance] postUnretweetWithParams:nil tweet:self completion:^(NSError *error) {
			if (error) {
				NSLog(@"Unretweet failed");
			} else {
				NSLog(@"Unretweet successful");
			}
		}];
	}
	
	return self.retweeted;
}

- (BOOL)favorite {
	self.favorited = !self.favorited;
	if (self.favorited) {
		self.favoriteCount++;
		// favorite
		[[TwitterClient sharedInstance] postFavoriteWithParams:nil tweet:self completion:^(NSError *error) {
			if (error) {
				NSLog(@"Favorite failed");
			} else {
				NSLog(@"Favorite successful");
			}
		}];
	} else {
		self.favoriteCount--;
		// unfavorite
		[[TwitterClient sharedInstance] postUnfavoriteWithParams:nil tweet:self completion:^(NSError *error) {
			if (error) {
				NSLog(@"Unfavorite failed");
			} else {
				NSLog(@"Unfavorite successful");
			}
		}];
	}
	
	return self.favorited;
}

@end
