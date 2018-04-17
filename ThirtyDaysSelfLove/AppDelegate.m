//
//  AppDelegate.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "AppDelegate.h"
#import "Model.h"
#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DefaultSHKConfigurator.h"
#import "MySHKCofig.h"
#import "SHKConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AffirmationViewController.h"
#import "SCVideoPlayerView.h"
#import "SCPlayer.h"
#import "CurrentUserModel.h"
#import "AffirmationsCollection.h"
#import "Affirmation.h"
#import "RecordViewController.h"
#import "VideoViewController.h"


static SCVideoPlayerView* bgVideoPlayer = nil;
@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if([[notification.userInfo objectForKey:@"type"] isEqualToString:@"affirmationReminder"])
    {
        if([identifier isEqualToString:@"View"])
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            AffirmationViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AffirmationsVC"];
            [self.window.rootViewController presentViewController:vc animated:true completion:nil];
        }
    }
    else if([[notification.userInfo objectForKey:@"type"] isEqualToString:@"videReminder"])
    {
        if([identifier isEqualToString:@"Record"])
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"RecordingNavVC"];
            [self.window.rootViewController presentViewController:vc animated:true completion:nil];
        }
    }
    
    
}

+(SCVideoPlayerView*)bgVideoPlayer
{
    return bgVideoPlayer;
}

+(void)setBgVideoPlayer:(SCVideoPlayerView*)player
{
    bgVideoPlayer = player;
}

- (void)willEnterFullscreen:(NSNotification*)notification
{
    NSLog(@"willEnterFullscreen");
    isFullScreen = YES;
}

- (void)willExitFullscreen:(NSNotification*)notification
{
    NSLog(@"willExitFullscreen");
    isFullScreen = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];

   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFullscreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];*/
    
    // Override point for customization after application launch.
    
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    [Model setBasePath:@"http://api.30daysselflove.com/mcs"];
    
    DefaultSHKConfigurator *configurator = [[MySHKCofig alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    AppDelegate.bgVideoPlayer = [[SCVideoPlayerView alloc] init];
    SCVideoPlayerView * player = AppDelegate.bgVideoPlayer;
    //[self.view insertSubview:player atIndex:0];
    player.frame = [UIScreen mainScreen].bounds;
    player.contentMode = UIViewContentModeScaleAspectFill;
    player.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bgvid" ofType:@"mov"];
    NSString* expandedPath = [filePath stringByExpandingTildeInPath];
    NSURL* vidURL = [NSURL fileURLWithPath:expandedPath];
    [player.player setItemByUrl:vidURL];
    player.player.loopEnabled = true;
    [player.player play];

    return YES;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (isFullScreen)
    {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
    else
    {
        if ([self.window.rootViewController.presentedViewController isKindOfClass: [UINavigationController class]] && [[(UINavigationController*)self.window.rootViewController.presentedViewController visibleViewController] isKindOfClass:[RecordViewController class]])
        {
            return UIInterfaceOrientationMaskAll;
        }
        else
        {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if(AppDelegate.bgVideoPlayer.superview) [AppDelegate.bgVideoPlayer.player play];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"url scheme: %@",url.scheme);
    if([url.scheme isEqualToString:@"thirtydays"])
    {
        NSUInteger followIndex = [url.pathComponents indexOfObject:@"follow"];
        if(followIndex != NSNotFound)
        {
            NSString * path = @"mcs/users/follow";
            NSDictionary *params = @{@"userToFollowID" : url.pathComponents[followIndex + 1]};
            [[CurrentUserModel sharedModel].queuedRemoteActions addObject:@[path, params]];
        }
        
        NSUInteger watchIndex = [url.pathComponents indexOfObject:@"watch"];
        if(watchIndex != NSNotFound)
        {
            NSString * path = @"watch";
            NSDictionary *params = @{@"videoID" : url.pathComponents[watchIndex + 1]};
            [[CurrentUserModel sharedModel].queuedLocalActions addObject:@[path, params]];
        }
        if([CurrentUserModel sharedModel].loggedIn)
        {
            [[CurrentUserModel sharedModel] commitQueuedRemoteActions];
            if([CurrentUserModel sharedModel].queuedLocalActions.count)
            {
                [[CurrentUserModel sharedModel].queuedLocalActions removeAllObjects];
                [self displayVideo:url.pathComponents[watchIndex + 1]];
            }
            
        }
        return YES;
    }
    else
    {
        // Note this handler block should be the exact same as the handler passed to any open calls.
        [FBSession.activeSession setStateChangeHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
        // attempt to extract a token from the url
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    
}

-(void)displayVideo:(NSString*)videoID
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    VideoViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    vc.videoID = videoID.intValue;
    vc.modalMode = true;
    [self.window.rootViewController presentViewController:vc animated:true completion:nil];

}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        
        CurrentUserModel * user = [CurrentUserModel sharedModel];
        [user loginWithFacebook];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI

    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

-(void)userLoggedOut
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main.storyboard"
                                                             bundle: nil];
    
    UINavigationController *controller = (UINavigationController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"IntroNavController"];
    
    LoginViewController *loginViewController = (LoginViewController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"LoginViewController"];
    controller.viewControllers = @[loginViewController];
    
    self.window.rootViewController = controller;
}

-(void)showMessage:(NSString*)alertText withTitle:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:alertText delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
