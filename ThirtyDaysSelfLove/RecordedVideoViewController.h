//
//  RecordedVideoViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/30/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPlayer.h"
#import "Video.h"


@class SCFilterSelectorView;
@class SCRecordSession;
@class VideoUploadViewController;

@interface RecordedVideoViewController : UIViewController<SCPlayerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    Video *_newVideo;
    UIImage *_thumbImage;
    __weak VideoUploadViewController *_uploadVc;
    CGFloat kbHeight;
    UITextField *currentTextField;
}

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet UISegmentedControl *privacySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *uploadSwitch;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *descriptionText;
@property (weak, nonatomic) IBOutlet UIView *previewView;


-(IBAction)doneClicked:(id)sender;
@end
