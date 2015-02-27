//
//  User.m
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

// keys for NSUserDefualts.
NSString * const kTokensKey = @"kTokensKey";
NSString * const kAccountsKey = @"kAccountsKey";
NSString * const kCurrentUserKey = @"kCurrentUserKey";

// NSNotificationCenter name
NSString * const UserLogoutNotification = @"UserLogoutNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (id) initWithDictionary:(NSDictionary *)dictionary  {
	self = [super init];
	if (self) {
		self.dictionary = dictionary;
		self.name = dictionary[@"name"];
		self.screenName = dictionary[@"screen_name"];
		self.tagLine = dictionary[@"description"];
		
		// image urls
		self.profileImageUrl = dictionary[@"profile_image_url"];
		self.backgroundImageUrl = dictionary[@"profile_background_image_url"];
		self.bannerUrl = dictionary[@"profile_banner_url"];
		
		// counts
		self.tweetCount = [dictionary[@"statuses_count"] integerValue];
		self.friendCount = [dictionary[@"friends_count"] integerValue];
		self.followerCount = [dictionary[@"followers_count"] integerValue];
	}
	
	return self;
}

static User *_currentUser = nil;

+ (User *)currentUser {
	if (_currentUser == nil) {
		NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
		if (data != nil) {
			NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
			_currentUser = [[User alloc] initWithDictionary:dictionary];
		}
	}
	
	return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (currentUser != nil) {
		NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
		[userDefaults setObject:data forKey:kCurrentUserKey];
		
		NSData *accountData = [userDefaults objectForKey:kAccountsKey];
		
		NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionary];
		if (accountData != nil) {
			NSDictionary *accounts = [NSJSONSerialization JSONObjectWithData:accountData options:0 error:NULL];
			accountDictionary = [accounts mutableCopy];
		}
		accountDictionary[currentUser.screenName] = currentUser.dictionary;
		
		NSData *newAccountData = [NSJSONSerialization dataWithJSONObject:accountDictionary options:0 error:NULL];
		[userDefaults setObject:newAccountData forKey:kAccountsKey];
		
	} else {
		[self removeUser:_currentUser];
	}
	
	_currentUser = currentUser;
	
	[userDefaults synchronize];
}

+ (void)removeUser:(User *)user{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSDictionary *storedAccounts = [self getStoredAccounts];
	NSMutableDictionary *newStoredAccounts = [storedAccounts mutableCopy];
	[newStoredAccounts removeObjectForKey:user.screenName];
	
	NSData *newAccountData = [NSJSONSerialization dataWithJSONObject:newStoredAccounts options:0 error:NULL];
	[userDefaults setObject:newAccountData forKey:kAccountsKey];
	
	if ([user.screenName isEqualToString:_currentUser.screenName]) {
		[userDefaults setObject:nil forKey:kCurrentUserKey];
	}
	
	[userDefaults synchronize];
}

+ (NSArray *)accounts {
	NSDictionary *storedAccounts = [self getStoredAccounts];
	NSMutableArray *accounts = [NSMutableArray array];
	NSArray *accountsRaw = [storedAccounts allValues];
	
	for (NSDictionary *dictionary in accountsRaw) {
		[accounts addObject:[[User alloc] initWithDictionary:dictionary]];
	}
	
	return accounts;
}

+ (void)logout {
	[User setCurrentUser:nil];
	[[TwitterClient sharedInstance].requestSerializer removeAccessToken];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:UserLogoutNotification object:nil];
}

// persistance related functions
#pragma mark NSUSerDefaults storage and retrival.
+ (NSDictionary *)getStoredAccounts {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *data;
	
	NSData *accountData = [userDefaults objectForKey:kAccountsKey];
	
	if (accountData != nil) {
		data = [NSJSONSerialization JSONObjectWithData:accountData options:0 error:NULL];
	} else {
		data = [NSDictionary dictionary];
	}
	
	return data;
}

+ (void)storeToken:(BDBOAuth1Credential *)token {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSJSONSerialization dataWithJSONObject:token options:0 error:NULL];
	[userDefaults setObject:data forKey:kTokensKey];
}

@end
