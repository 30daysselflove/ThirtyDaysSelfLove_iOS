//
//  AppDelegate.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class SCVideoPlayerView;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    @public
    BOOL isFirstLoad;
    @protected
    BOOL isFullScreen;
}

+(SCVideoPlayerView*)bgVideoPlayer;

-(void)displayVideo:(NSString*)videoID;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@property (strong, nonatomic) UIWindow *window;




@end

