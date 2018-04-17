//
//  ViewController.h
//  TUS Test
//
//  Created by Adam Dougherty on 10/1/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"
#import "HeartProgressIndicator.h"

@class TUSResumableUpload;

@interface VideoUploadViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSUInteger _retries;
    TUSResumableUpload *_currentUpload;
}
-(IBAction)share:(id)sender;
-(IBAction)doneClicked:(id)sender;
-(void)startUpload;
@property NSURL *videoFileURI;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property Video *videoModel;
@property (strong) UIImage *thumbImage;
@property (weak, nonatomic) IBOutlet HeartProgressIndicator *progressIndicator;
@end

