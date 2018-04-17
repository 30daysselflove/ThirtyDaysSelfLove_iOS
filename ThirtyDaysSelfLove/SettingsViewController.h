//
//  SettingsViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 11/30/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

+(void)cancelNotificationForType:(NSString*)type;

-(IBAction)scheduledAffirmationSwitchChanged:(id)sender;
-(IBAction)scheduledRecordingSwitchChanged:(id)sender;
-(IBAction)logoutClicked:(id)sender;
-(IBAction)timeButtonClicked:(id)sender;
-(IBAction)kingdmButtonClicked:(id)sender;
-(void)recordingDateSet:(NSDate*)dt;
@property (weak, nonatomic) IBOutlet UISwitch *scheduledAffirmationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scheduledRecordingSwitch;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@end
