//
//  VideoViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "VideoViewController.h"
#import "Video.h"
#import "SCVideoPlayerView.h"
#import "SupportCommentCell.h"
#import "CurrentUserModel.h"
#import "MPMoviePlayerViewControllerAuto.h"
#import "DateTools.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

@synthesize video;


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUInteger idx = 0;
    if(popup.tag == 1)
    {
        if(buttonIndex == 0)
        {
            self.video.reports = @([self.video.reports intValue] + 1);
            [self.video save];
        }
    }
}

-(IBAction)actionButtonClicked:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Actions:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:nil,
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentInput.delegate = self;
    
    self.title = @"";
    self.videoInfoLabel.text = @"";
    self.submittedByLabel.text = @"";
    self.titleLabel.text = @"";
    
    __block VideoViewController *me = self;
    self.video = [[Video alloc] initWithID:(int)self.videoID];
 
        [self.progressIndicator toggleActivityMode];
         [self.video loadWithCallback:^(bool success)
          {
            [self.progressIndicator endActivityMode];
              if(!success)
              {
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:@"Could not connect to 30 Days Self Love Network" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                  [alert show];
                  return;
              }
              
              CurrentUserModel * user = [CurrentUserModel sharedModel];
              if([me.video.userID unsignedIntValue] == user.id)
              {
                  me.video.newcomments = [NSNumber numberWithInt:0];
                  [me.video save];
              }
              
              playerViewController = [[MPMoviePlayerViewControllerAuto alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.video.mediaURL]]];
              
              [_videoPlayerView addSubview:playerViewController.view];
              
              //play movie
              MPMoviePlayerController *player = [playerViewController moviePlayer];
              player.controlStyle = MPMovieControlStyleEmbedded;
              [player play];
              playerViewController.view.frame = CGRectMake(0, 0, _videoPlayerView.bounds.size.width, _videoPlayerView.bounds.size.height);
            
              self.title = @"";
              self.titleLabel.text = self.video.title;
              self.videoInfoLabel.text = self.video.description;
              NSDate * submittedTime = [NSDate dateFromMysqlTimestamp:self.video.uploadDate];
              
              NSString * submittedTimeString = [submittedTime timeAgoSinceNow];
              NSString *firstLowChar = [[submittedTimeString substringToIndex:1] lowercaseString];
              NSString *lowedString = [submittedTimeString stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstLowChar];
              self.submittedByLabel.text = [NSString stringWithFormat:@"Submitted by %@ %@", self.video.username, lowedString];
            
              [self.commentsListTable reloadData];
              [self.view bringSubviewToFront:self.commentView];
              self.commentView.hidden = false;
              self.commentView.alpha = 1;
          }];
    
    
  
    // Do any additional setup after loading the view.
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    [aValue getValue:&keyboardBounds];
    CGSize kbSize = keyboardBounds.size;
    
    if(!keyboardIsShowing)
    {
        keyboardIsShowing = YES;
        origCommentViewConstraintY = self.commentViewBottomConstraint.constant;
        self.commentViewBottomConstraint.constant = kbSize.height;
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if(keyboardIsShowing)
    {
        keyboardIsShowing = NO;
        self.commentViewBottomConstraint.constant = origCommentViewConstraintY;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if(playerViewController.moviePlayer.fullscreen != true)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    if(self.modalMode)
    {
        self.commentViewBottomConstraint.constant = 0;
        self.closeButton.hidden = false;
        self.closeButton.userInteractionEnabled = true;
    }
    else
    {
        self.closeButton.hidden = true;
        self.closeButton.userInteractionEnabled = false;
    }
}

-(IBAction)closeButtonClicked:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    if(playerViewController.moviePlayer.fullscreen != true)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [playerViewController.moviePlayer stop];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * commentData = [self.video.comments objectAtIndex:indexPath.row];

    NSMutableArray * rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    SupportCommentCell *cell = (SupportCommentCell*) [tableView dequeueReusableCellWithIdentifier:@"SupportCommentCell"];
    NSDate * submittedTime = [NSDate dateFromMysqlTimestamp:[commentData objectForKey:@"postDate"]];
    cell.timeLabel.text = [submittedTime timeAgoSinceNow];
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    [cell setComment:[commentData objectForKey:@"comment"] withName:[commentData objectForKey:@"realName"]];
    
    return cell;

}

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath * indexPath = [self.commentsListTable indexPathForCell:cell];
    NSDictionary * comment = [self.video.comments objectAtIndex:indexPath.row];
    
    [self.video removeComment:[(NSString*)[comment objectForKey:@"id"] integerValue] withCallback:^(bool success)
     {
         NSIndexPath * indexPath2 = [self.commentsListTable indexPathForCell:cell];
         [self.commentsListTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath2, nil] withRowAnimation:UITableViewRowAnimationTop];
     }];
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    CurrentUserModel * user = [CurrentUserModel sharedModel];
    if([self.video.userID unsignedIntValue] == user.id)
    {
        return YES;
    }
    
    NSIndexPath * indexPath = [self.commentsListTable indexPathForCell:cell];
    NSDictionary * comment = [self.video.comments objectAtIndex:indexPath.row];
    if([[comment objectForKey:@"userID"] unsignedIntValue] == user.id)
    {
        return YES;
    }
    
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count: %lu", (unsigned long)self.video.comments.count);
    return self.video.comments.count;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)postCommentClicked:(id)sender
{
    self.postCommentButton.enabled = false;
    
    [self.video postComment:self.commentInput.text withCallback:^(bool success)
     {
         
         if(success)
         {
             [UIView beginAnimations:nil context:NULL];
             [UIView setAnimationDuration:0.5];
             [self.commentView setAlpha:0.0];
             [UIView commitAnimations];
             
             [self.commentsListTable beginUpdates];
             NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:self.video.comments.count -1 inSection:0];
             NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
             [self.commentsListTable insertRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationBottom];
             [self.commentsListTable endUpdates];
             [self.commentsListTable scrollToRowAtIndexPath:rowToReload atScrollPosition:UITableViewScrollPositionBottom animated:true];
             [self.commentInput resignFirstResponder];
         }
         else
         {
             self.postCommentButton.enabled = true;
         }
     }];
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
