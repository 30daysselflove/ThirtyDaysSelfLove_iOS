//
//  FirstViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;
@class VideosCollection;

@interface IntroViewController : UIViewController
{
    Video *_video;
    VideosCollection *_videosCollection;
}


@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;


@end

