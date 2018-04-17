//
//  VideosListViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "ProfileViewController.h"
#import "VideosCollection.h"
#import "Video.h"
#import "VideoListCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+NSString_FrameToQueryString.h"
#import "CurrentUserModel.h"
#import "BubblingActionCell.h"
#import "VideoViewController.h"
#import "Profile.h"
#import "DateTools.h"
#import "NSString+MD5.h"
#import "ShareKit.h"

#define INVITE_HASH_SECRET @"30bjd8891bb!j38abMiiC"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.profileTitleLabel.text = @"";
    self.userProfileTextfield.text = @"";
    self.userTitleLabel.text = @"";
    self.followingLabel.text = @"";
    self.followButton.hidden = true;

    CurrentUserModel * userModel = [CurrentUserModel sharedModel];
    if(!self.userID) self.userID = userModel.id;

    if(userModel.id == self.userID)
    {
        _isMine = true;
    }
   
    if(!_isMine) self.profileTitleLabel.text = @"Profile";
    else self.profileTitleLabel.text = @"My Profile";
    
    _profile = [[Profile alloc] initWithID:self.userID];
    self.editHintLabel.hidden = true;
    self.userProfileTextfield.textContainer.maximumNumberOfLines = 3;
    [self.progressIndicator toggleActivityMode];
}

-(IBAction)followButtonClicked:(id)sender
{
    [_profile followWithCallback:^(bool success)
    {
        self.followingLabel.text = [_profile.following boolValue] ? @"Following" : @"Follow";
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(hintLabel) [hintLabel removeFromSuperview];
    [_profile loadWithCallback:^(bool success)
     {
         if(!success)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:@"Could not connect to 30 Days Self Love Network" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return;
         }
         [self.progressIndicator endActivityMode];
         self.userTitleLabel.text = _profile.realName;
         self.userProfileTextfield.text = _profile.profileHeader;
         self.followingLabel.text = [_profile.following boolValue] ? @"Following" : @"Follow";

         if(!_isMine)
         {
             self.userProfileTextfield.editable = false;
             self.profileTitleLabel.text = _profile.realName;
             self.followingLabel.hidden = false;
             self.followButton.hidden = false;
             
         }
         else
         {
             self.followingLabel.hidden = true;
             self.followButton.hidden = true;
             
             if(_profile.videos.count == 0)
             {
                 hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width /2 - 150, 135, 300, 300)];
                 hintLabel.numberOfLines = 0;
                 hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
                 hintLabel.textAlignment = NSTextAlignmentCenter;
                 hintLabel.font = [UIFont fontWithName:@"Noteworthy" size:20.0];
                 hintLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
                 hintLabel.layer.shadowRadius = 2.5f;
                 hintLabel.layer.shadowOpacity = .9;
                 hintLabel.layer.shadowOffset = CGSizeZero;
                 hintLabel.layer.masksToBounds = NO;
                 hintLabel.text = @"Get Started Today because YOU are worth it!";
                 [self.view addSubview:hintLabel];
             }
             self.userProfileTextfield.editable = true;
             self.userProfileTextfield.delegate = self;
             if(_profile.profileHeader.length == 0) self.editHintLabel.hidden = false;
         }
         [self.videosList reloadData];
     }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - Table Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video * video = (Video*) [_profile.videos get:indexPath.row];
    VideoListCell *cell = (VideoListCell*) [tableView dequeueReusableCellWithIdentifier:@"VideoListCell"];
    
    
    [cell.usernameButton addTarget:cell action:@selector(fireAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.newcommentCountView.hidden = true;
    if(_isMine)
    {
        [cell.extraActionsButton addTarget:cell action:@selector(fireAction:) forControlEvents:UIControlEventTouchUpInside];
        if(video.newcomments.integerValue > 0)
        {
            cell.newcommentCountView.hidden = false;
            cell.newcommentCountLabel.text = [NSString stringWithFormat:@"%li", (long)video.newcomments.integerValue];
            cell.newcommentCountView.layer.shadowColor = [UIColor whiteColor].CGColor;
            cell.newcommentCountView.layer.shadowRadius = 6.0;
            cell.newcommentCountView.layer.shadowOpacity = .5;
            cell.newcommentCountView.layer.shadowOffset = CGSizeZero;
            cell.newcommentCountView.layer.masksToBounds = NO;
        }
    }
    else
    {
        cell.extraActionsButton.hidden = true;
    }
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(fireAction:)];
    [cell.videoThumbView addGestureRecognizer:tap];
    cell.videoThumbView.userInteractionEnabled = YES;
    
    const CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor blackColor];
    
    // Create the attributes
    NSDictionary *attrs = @{ NSFontAttributeName : boldFont,
                             NSForegroundColorAttributeName : foregroundColor};
    
    NSDictionary *subAttrs = @{
                               NSFontAttributeName : regularFont
                               };
    
    const NSRange range = NSMakeRange(0,video.title.length); // range of " 2012/10/14 ". Ideally this should not be hardcoded
    
    NSString * builtString = [NSString stringWithFormat:@"%@ %@", video.title, video.description];
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:builtString attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    
    [cell.videoInfoLabel setAttributedText:attributedText];
    [cell.usernameButton setTitle:video.username forState:UIControlStateNormal];
    
    NSDate * submittedTime = [NSDate dateFromMysqlTimestamp:video.uploadDate];
    cell.timeLabel.text = [submittedTime timeAgoSinceNow];
    cell.delegate = self;
    
    NSString * frameQueryString = [NSString queryStringUsingFrame:cell.videoThumbView.frame];
    [cell.videoThumbView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@?%@", video.thumbImageURL, frameQueryString]]];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _profile.videos.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableViewCell:(UITableViewCell *)cell didFireActionForSender:(id)sender
{
    NSIndexPath *indexPath = [self.videosList indexPathForCell:cell];
    
    id realSender;
    if([sender isKindOfClass:[UIControl class]])
    {
        realSender = sender;
    }
    else //Gesture Recognizer
    {
        realSender = [(UIGestureRecognizer*) sender view];
    }
    
    Video * video = (Video*) [_profile.videos get:indexPath.row];
    VideoListCell *typedCell = (VideoListCell*) cell;
   
    if(realSender == typedCell.extraActionsButton)
    {
        _actionedVideo = video;
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Actions:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:
                                @"Share",
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        //Goto video
        VideoViewController *nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
        nextViewController.videoID = video.id;
        [self.navigationController pushViewController:nextViewController animated:true];
    }
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUInteger idx = 0;
    if(popup.tag == 1)
    {
        if(buttonIndex == 0)
        {
            for (Video *video in _profile.videos) {
                if(video.id == _actionedVideo.id)
                {
                    [_profile.videos remove:idx];
                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    [self.videosList deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
                    break;
                }
                idx++;
            }
            [_actionedVideo destroy];

        }
        else if(buttonIndex == 1)
        {
            NSString *videoIDString = [NSString stringWithFormat:@"%lu-%@", (unsigned long)_actionedVideo.id, INVITE_HASH_SECRET];
            NSString *videoIDHash = [videoIDString md5];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://join.30daysselflove.com/video/%lu/%@",
                                               (unsigned
                                                long)_actionedVideo.id,
                                               videoIDHash]];
            SHKItem *item = [SHKItem URL:url title:@"I'm sharing a video of my personal journey" contentType:SHKURLContentTypeWebpage];
            
            // Get the ShareKit action sheet
            SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
            
            // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
            // but sometimes it may not find one. To be safe, set it explicitly
            [SHK setRootViewController:self];
            
            // Display the action sheet
            [actionSheet showFromToolbar:self.navigationController.toolbar];

        }
    }
}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.editHintLabel.hidden = true;
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
    
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [self.view removeGestureRecognizer:tapRec];
    [[self view] endEditing: YES];
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    CurrentUserModel * userModel = [CurrentUserModel sharedModel];
    [userModel setData:@{@"profileHeader" : textView.text}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
