//
//  IntroVideoViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/12/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "IntroVideoViewController.h"


@implementation IntroVideoViewController

-(void)viewWillAppear:(BOOL)animated
{
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"introvid" ofType:@"mov"]]];
    
    [self.view insertSubview:playerViewController.view atIndex:0];
    
    //play movie
    MPMoviePlayerController *player = [playerViewController moviePlayer];
    player.controlStyle = MPMovieControlStyleNone;
    
    [player play];
    playerViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [playerViewController.moviePlayer stop];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)closeClicked:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
