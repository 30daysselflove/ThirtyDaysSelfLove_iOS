//
//  VideoViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SWTableViewCell.h"
#import "HeartProgressIndicator.h"

@class Video;
@class SCVideoPlayerView;

@interface VideoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    SCVideoPlayerView* _player;
    MPMoviePlayerViewController * playerViewController;
    BOOL keyboardIsShowing;
    CGFloat origCommentViewConstraintY;
    
}


-(IBAction)postCommentClicked:(id)sender;
-(IBAction)actionButtonClicked:(id)sender;
-(IBAction)closeButtonClicked:(id)sender;
@property NSUInteger videoID;
@property BOOL modalMode;
@property Video *video;
@property (weak, nonatomic) IBOutlet UIView *fullView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UILabel *videoInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *submittedByLabel;
@property (weak, nonatomic) IBOutlet UITableView *commentsListTable;
@property (weak, nonatomic) IBOutlet UIButton *postCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextField *commentInput;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet HeartProgressIndicator *progressIndicator;

@end
