//
//  VideoListCell.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/7/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubblingActionCell.h"

@interface VideoListCell : BubblingActionCell


@property (weak, nonatomic) IBOutlet UIImageView *videoThumbView;
@property (weak, nonatomic) IBOutlet UIView *newcommentCountView;
@property (weak, nonatomic) IBOutlet UILabel *videoInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *newcommentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *extraActionsButton;
@end
