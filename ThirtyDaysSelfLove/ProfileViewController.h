//
//  VideosListViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideosCollection.h"
#import "BubblingActionCell.h"
#import "HeartProgressIndicator.h"
@class Profile;
@class Video;

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BubblingActionCellDelegate, UITextViewDelegate, UIActionSheetDelegate>
{
    Profile * _profile;
    Video *_actionedVideo;
    BOOL _isMine;
    UILabel *hintLabel;
}


@property (weak, nonatomic) IBOutlet UILabel *profileTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UITableView *videosList;
@property (weak, nonatomic) IBOutlet UILabel *editHintLabel;
@property (weak, nonatomic) IBOutlet UITextView *userProfileTextfield;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet HeartProgressIndicator *progressIndicator;
@property (assign) NSUInteger userID;

@end
