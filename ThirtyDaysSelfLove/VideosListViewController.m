//
//  VideosListViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "VideosListViewController.h"
#import "VideosCollection.h"
#import "Video.h"
#import "VideoListCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+NSString_FrameToQueryString.h"
#import "CurrentUserModel.h"
#import "BubblingActionCell.h"
#import "VideoViewController.h"
#import "ProfileViewController.h"
#import "ShareKit.h"
#import "SVPullToRefresh.h"
#import "DateTools.h"
#import "NSString+MD5.h"

NSString * const INVITE_HASH_SECRET = @"30bjd8891bb!j38abMiiC";

@interface VideosListViewController ()

@end

@implementation VideosListViewController
-(IBAction)invite:(id)sender
{
    // Create the item to share (in this example, a url)
    NSUInteger userID = [CurrentUserModel sharedModel].id;
    NSString *userIDString = [NSString stringWithFormat:@"%lu-%@", (unsigned long)userID, INVITE_HASH_SECRET];
    NSString *userIDHash = [userIDString md5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://join.30daysselflove.com/user/%lu/%@", (unsigned long)userID,
    userIDHash]];
    SHKItem *item = [SHKItem URL:url title:@"Join me on my personal journey by starting your own."
                     contentType:SHKURLContentTypeWebpage];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
  
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    actionSheet.title = @"Invite";
    
    // Display the action sheet
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

-(void)fadeInTable
{
    __block VideosListViewController * me = self;
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         me.videosList.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    //self.navigationController.delegate = self;

    self.videosList.alpha = 0;
    _videos = [[VideosCollection alloc] init];
    
    self.context = VideoListEveryone; //For Testing
    _videos.videoListContext = self.context;

    self.videosList.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.listTypeSelector.selectedSegmentIndex = self.context;
    [self.progressIndicator toggleActivityMode];
    [_videos loadWithCallback:^(bool success)
    {
        if(!success)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:@"Could not connect to 30 Days Self Love Network" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self.progressIndicator endActivityMode];
        [self.videosList reloadData];
        [self fadeInTable];
        [self.videosList addInfiniteScrollingWithActionHandler:^{
            
            [_videos loadMoreWithCallback:^(bool success)
            {
                NSMutableArray* rowsToReload = [NSMutableArray new];
                
                NSUInteger mostRecentlyAddedCount = _videos.mostRecentlyLoadedModels.count;
                for (NSUInteger i = 0; i < mostRecentlyAddedCount; i++) {
                      NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:_videos.count - mostRecentlyAddedCount -1 + i inSection:0];
                    [rowsToReload addObject:rowToReload];
                }
                [self.videosList beginUpdates];
                [self.videosList insertRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationTop];
                [self.videosList endUpdates];
                [self.videosList.infiniteScrollingView stopAnimating];
            }];
            
        }];
    }];
     
}

-(IBAction)listTypeSegementChanged:(id)sender
{
    self.context = self.listTypeSelector.selectedSegmentIndex;
    _videos.videoListContext = self.context;
    
    [self.progressIndicator toggleActivityMode];
    [_videos removeAll];
    if(hintLabel) [hintLabel removeFromSuperview];
    [self.videosList reloadData];
    [_videos loadWithCallback:^(bool success)
     {
         if(_videos.videoListContext == 0 && !_videos.count)
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
             hintLabel.text = @"Share your journey with your friends.\nGo to the top right to send an invite.\nThen ask your friends to do the same.";
             [self.view addSubview:hintLabel];
         }
         [self.progressIndicator endActivityMode];
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
    Video * video = (Video*) [_videos get:indexPath.row];
    VideoListCell *cell = (VideoListCell*) [tableView dequeueReusableCellWithIdentifier:@"VideoListCell"];
    
    
    [cell.usernameButton addTarget:cell action:@selector(fireAction:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(fireAction:)];
    [cell.videoThumbView addGestureRecognizer:tap];
    cell.videoThumbView.userInteractionEnabled = YES;
    NSDate * submittedTime = [NSDate dateFromMysqlTimestamp:video.uploadDate];
    cell.timeLabel.text = [submittedTime timeAgoSinceNow];
    
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
    cell.delegate = self;
    
    NSString * frameQueryString = [NSString queryStringUsingFrame:cell.videoThumbView.frame];
    [cell.videoThumbView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@?%@", video.thumbImageURL, frameQueryString]]];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _videos.count;
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
    
    
    Video * video = (Video*) [_videos get:indexPath.row];
    VideoListCell *typedCell = (VideoListCell*) cell;
    if(realSender == typedCell.usernameButton)
    {
        //Goto user
        ProfileViewController *nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        nextViewController.userID = [video.userID unsignedIntegerValue];
        [self.navigationController pushViewController:nextViewController animated:true];
    }
    else if(realSender == typedCell.videoThumbView)
    {
        //Goto video
        VideoViewController *nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
        nextViewController.videoID = video.id;
        [self.navigationController pushViewController:nextViewController animated:true];
    }
    
}

-(void)pushAfterWait:(UIViewController*) controller
{
    [self.navigationController pushViewController:controller animated:true];
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
