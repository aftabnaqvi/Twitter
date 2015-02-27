//
//  ProfileCell.h
//  Twitter
//
//  Created by Syed Naqvi on 2/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "User.h"

@protocol ProfileCellDelegate <NSObject>

-(void) pageChanged: (UIPageControl*) pageControl;

@end

@interface ProfileCell : UITableViewCell

@property (strong, nonatomic) User *user;
@property (nonatomic, weak) id<ProfileCellDelegate> delegate;

@end
