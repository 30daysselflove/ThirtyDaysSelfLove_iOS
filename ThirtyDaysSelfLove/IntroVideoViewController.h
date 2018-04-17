//
//  IntroVideoViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/12/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface IntroVideoViewController : UIViewController
{
    MPMoviePlayerViewController * playerViewController;
}

-(IBAction)closeClicked:(id)sender;
@end
