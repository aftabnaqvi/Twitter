//
//  User.h
//  Twitter
//
//  Created by Syed Naqvi on 2/18/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDBOAuth1RequestOperationManager.h"

extern NSString * const UserLogoutNotification;

@interface User : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *screenName;
@property(nonatomic, strong) NSString *profileImageUrl;
@property(nonatomic, strong) NSString *tagLine;
@property (nonatomic) NSInteger tweetCount;
@property (nonatomic) NSInteger friendCount;
@property (nonatomic) NSInteger followerCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;
+ (NSArray *)accounts;

+ (void)removeUser:(User *)user;
+ (void)logout;
+ (void)storeToken:(BDBOAuth1Credential *)token;
@end
