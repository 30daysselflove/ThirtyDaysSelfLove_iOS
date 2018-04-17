//
//  CustomTabController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 11/24/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "CustomTabController.h"
#import "PropagatingViewController.h"
#import "AppDelegate.h"
#import "SCVideoPlayerView.h"
#import "CurrentUserModel.h"

@implementation CustomTabController


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

-(UIViewController*) viewController: (NSString*) storyboardID withTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController* vc;
    if([storyboardID isEqualToString:@"Profile"])
    {
        vc = [[PropagatingViewController alloc] initWithNavControllerWithSubViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"]];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    }
    else if([storyboardID isEqualToString:@"VideosBrowser"])
    {
        vc = [[PropagatingViewController alloc] initWithNavControllerWithSubViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"VideosListViewController"]];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    }
    else
    {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    }
    vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    return vc;
}

-(void)viewDidLoad
{
    if(AppDelegate.bgVideoPlayer)
    {
        [AppDelegate.bgVideoPlayer.player pause];
        [AppDelegate.bgVideoPlayer removeFromSuperview];
        
    }
    UIImage *navBackgroundImage = [UIImage imageNamed:@"bg-navbar.png"];
    self.wantsFullScreenLayout = true;
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    _dummyController = [[UIViewController alloc] init];
    self.viewControllers = @[
                           [self viewController:@"VideosBrowser" withTabTitle:@"" image:[[UIImage imageNamed:@"icon-share.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]],
                           [self viewController:@"SettingsVC" withTabTitle:@"" image:[[UIImage imageNamed:@"icon-settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]],
                           _dummyController,
                            [self viewController:@"AffirmationsVC" withTabTitle:@"" image:[[UIImage imageNamed:@"icon-calendar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]],
                           [self viewController:@"Profile" withTabTitle:@"" image:[[UIImage imageNamed:@"icon-person.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]]
                          ];
  
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(_recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width * 1.6, buttonImage.size.height * 1.6);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y;
        button.center = center;
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}
-(void)_recordButtonClicked:(id)sender
{
    UIViewController * recordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordingNavVC"];
    [self presentViewController:recordVC animated:true completion:^(void)
     {
         
     }];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"icon-record.png"] highlightImage:[UIImage imageNamed:@"icon-record.png"]];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app->isFirstLoad = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLoad"] ? true : [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLoad"];
    if(app->isFirstLoad)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstUse"];
        self.selectedIndex = 1;
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    NSMutableArray* localActions = [CurrentUserModel sharedModel].queuedLocalActions;
    
    if(localActions.count)
    {
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        [app displayVideo: [(NSDictionary*)[(NSArray*)[localActions objectAtIndex:localActions.count - 1] objectAtIndex:1] objectForKey:@"videoID"]];
        [localActions removeAllObjects];
    }
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if(viewController == _dummyController)
    {
        return NO;
    }
    return YES;
}

@end
