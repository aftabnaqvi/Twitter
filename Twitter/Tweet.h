//
//  Tweet.h
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user; // who tweeted it.
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic) NSInteger favoriteCount;

@property (nonatomic) BOOL retweeted;
@property (nonatomic) BOOL favorited;

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *replyToIdString;
@property (nonatomic, strong) NSString *retweetIdString;
@property (nonatomic, strong) Tweet *retweetedTweet;

- (id) initWithDictionary:(NSDictionary *)dictionary;
- (id) initWithText:(NSString *)text replyToTweet:(Tweet *)replyToTweet;
- (BOOL) retweet;
- (BOOL) favorite;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end