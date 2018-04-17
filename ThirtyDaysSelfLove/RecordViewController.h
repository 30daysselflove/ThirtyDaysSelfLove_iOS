//
//  RecordViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/29/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface RecordViewController : UIViewController <SCRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *librarySelectorButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIImageView *recordIndicator;


-(IBAction)recordTapped:(id)sender;
-(IBAction)stopTapped:(id)sender;
-(IBAction)reverseTapped:(id)sender;
-(IBAction)closeTapped:(id)sender;
-(IBAction)librarySelectorTapped:(id)sender;
@end
