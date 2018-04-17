//
//  ResetSentViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/19/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "ResetSentViewController.h"
#import "AppDelegate.h";

@implementation ResetSentViewController


-(void)viewWillAppear:(BOOL)animated
{
    [self.view insertSubview:AppDelegate.bgVideoPlayer atIndex:0];
}

-(IBAction)signInClicked:(id)sender
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
}
@end
