//
//  FirstViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "IntroViewController.h"
#import "Video.h"
#import "CurrentUserModel.h"
#import "VideosCollection.h"
#import "Model.h"
#import "AnimatedGif.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SCPlayer.h"
#import "SCVideoPlayerView.h"
#import "AppDelegate.h"


@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
  
    UIView * filter = [UIView new];
    filter.frame = self.view.frame;
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.25;
    [self.view insertSubview:filter atIndex:0];
    [self setNeedsStatusBarAppearanceUpdate];
    
}

-(void)moviePlayBackDidFinish:(NSNotification*)notifcation
{
    NSLog(@"something hapepend: %@", notifcation);
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"frame: %@", NSStringFromCGRect(self.view.frame));
    [self.navigationController setNavigationBarHidden:true];
    
    [self.view insertSubview:AppDelegate.bgVideoPlayer atIndex:0];
    [AppDelegate.bgVideoPlayer.player play];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    // Dispose of any resources that can be recreated.
}

@end
