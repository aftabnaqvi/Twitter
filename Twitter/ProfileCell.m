//
//  ProfileCell.m
//  Twitter
//
//  Created by Syed Naqvi on 2/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ProfileCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *profilePageControl;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *namePageLeftConstraint;

@end

@implementation ProfileCell

- (void)awakeFromNib {
	// Initialization code
	
	// disable selection on cell
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
}

- (void)setUser:(User *)user {
	
	// sanity check.
	if(user == nil)
		return;
	
	// rounded corners and border for profile image.
	CALayer *layer = [self.profileImageView layer];
	[layer setCornerRadius:5.0];
	[layer setBorderColor:[[UIColor whiteColor] CGColor]];
	[layer setBorderWidth:3.0];
	[layer setMasksToBounds:YES];

	// hiding profilePageControl if tehre is no tagline.
	if(!user.tagLine || [user.tagLine isEqualToString:@""]) {
		[self.profilePageControl setHidden:YES];
	} else {
		[self.profilePageControl setHidden:NO];
	}
	
	[self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:user.profileImageUrl]]
	    placeholderImage:nil
		success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
			[self.profileImageView setImage:image];
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
			NSLog(@"failed loading profile image: %@", error);
		}
	 ];

	self.nameLabel.text = user.name;
	self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
	self.taglineLabel.text = user.tagLine;
	
	// Fixed line wrapping issue with auto layout
	self.taglineLabel.preferredMaxLayoutWidth = self.taglineLabel.bounds.size.width;
	
	// setting counts ...
	self.tweetCountLabel.text = [self getFormattedCount:user.tweetCount];
	self.followingCountLabel.text = [self getFormattedCount:user.friendCount];
	self.followerCountLabel.text = [self getFormattedCount:user.followerCount];
}

- (NSString *) getFormattedCount:(NSInteger)count {
	if (count >= 1000000) {
		return [NSString stringWithFormat:@"%.1fM", (double)count / 1000000];
	} else if (count >= 10000) {
		return [NSString stringWithFormat:@"%.1fK", (double)count / 1000];
	} else if (count >= 1000) {
		return [NSString stringWithFormat:@"%ld,%ld", (long)count / 1000, (long)count % 1000];
	} else {
		return [NSString stringWithFormat:@"%ld", (long)count];
	}
}

- (IBAction)onPageControlValueChanged:(UIPageControl *)sender {
	if (sender.currentPage == 0) {
		[UIView animateWithDuration:.24 animations:^{
			self.namePageLeftConstraint.constant = 0;
			[self layoutIfNeeded];
		}];
	} else {
		[UIView animateWithDuration:.24 animations:^{
			self.namePageLeftConstraint.constant = -self.nameLabel.bounds.size.width - 32;
			[self layoutIfNeeded];
		}];
	}
	[self.delegate pageChanged:sender];
}

@end
