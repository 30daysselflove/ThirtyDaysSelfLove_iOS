//
//  SettingsViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 11/30/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "SettingsViewController.h"
#import "CurrentUserModel.h"
#import "AppDelegate.h"
#import "DatePickerViewController.h"
#import "TermsViewController.h"

@implementation SettingsViewController


+(void)cancelNotificationForType:(NSString*)type
{
    NSArray * notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (id notification in notifications) {
        NSDictionary * userInfo = [(UILocalNotification*)notification userInfo];
        {
            if([[userInfo objectForKey:@"type"] isEqualToString:type])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

-(IBAction)timeButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"datePickerSegue" sender:self];
}

-(IBAction)kingdmButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.kingdm.com"]];
}

-(void)viewDidLoad
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if(app->isFirstLoad)
    {
        [self registerAffirmationNotification];
    }
    self.scheduledRecordingSwitch.on = false;
    self.scheduledAffirmationSwitch.on = false;
    self.timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.timeButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.timeButton setTitle:@"Time not set" forState:UIControlStateNormal];


    NSArray * notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (id notification in notifications) {
        NSDictionary * userInfo = [(UILocalNotification*)notification userInfo];
        {
            if([[userInfo objectForKey:@"type"] isEqualToString:@"videoReminder"])
            {
                self.scheduledRecordingSwitch.on = true;
                NSDate * notificationTime = [(UILocalNotification*)notification fireDate];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"h:mm a"];
                [self.timeButton setTitle:[formatter stringFromDate:notificationTime] forState:UIControlStateNormal];
                continue;
            }
            else if([[userInfo objectForKey:@"type"] isEqualToString:@"affirmationReminder"])
            {
                self.scheduledAffirmationSwitch.on = true;
                continue;
            }
        }
    }
}

-(void)recordingDateSet:(NSDate*)dt
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    [self.timeButton setTitle:[formatter stringFromDate:dt] forState:UIControlStateNormal];
    [self registerRecordingNotification:dt];
}

-(void)registerRecordingNotification:(NSDate*)dt
{
    [SettingsViewController cancelNotificationForType:@"videoReminder"];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.repeatInterval = NSDayCalendarUnit;
    localNotification.fireDate = dt;
    localNotification.alertBody = @"It's time for YOU!";
    localNotification.userInfo = @{@"type" : @"videoReminder"};
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertAction = @"Record";
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)registerAffirmationNotification
{
    NSDate* now = [NSDate date];
    
    NSDateComponents* tomorrowComponents = [NSDateComponents new] ;
    tomorrowComponents.day = 1 ;
    NSCalendar* calendar = [NSCalendar currentCalendar] ;
    NSDate* tomorrow = [calendar dateByAddingComponents:tomorrowComponents toDate:now options:0] ;
    
    NSDateComponents* tomorrowAt12PMComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:tomorrow] ;
    tomorrowAt12PMComponents.hour = 12 ;
    NSDate* tomorrowAt12PM = [calendar dateFromComponents:tomorrowAt12PMComponents];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.repeatInterval = NSDayCalendarUnit;
    localNotification.fireDate = tomorrowAt12PM;
    localNotification.alertBody = @"Get inspired by today's affirmation!";
    localNotification.userInfo = @{@"type" : @"affirmationReminder"};
    localNotification.alertAction = @"View";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(IBAction)scheduledAffirmationSwitchChanged:(id)sender
{
    if(self.scheduledAffirmationSwitch.on)
    {
        [self registerAffirmationNotification];
        
    }
    else
    {
        [SettingsViewController cancelNotificationForType:@"affirmationReminder"];
    }
}

-(IBAction)scheduledRecordingSwitchChanged:(id)sender
{
    if(self.scheduledRecordingSwitch.on)
    {
        [self performSegueWithIdentifier:@"datePickerSegue" sender:self];
    }
    else
    {
        [self.timeButton setTitle:@"Time not set" forState:UIControlStateNormal];
        [SettingsViewController cancelNotificationForType:@"videoReminder"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"datePickerSegue"])
    {
        DatePickerViewController *vc = [segue destinationViewController];
        vc.settingsVc = self;
    }
    else if ([[segue identifier] isEqualToString:@"termsSegue"])
    {
        TermsViewController *vc = [segue destinationViewController];
        vc.type = 1;
    }
    else if ([[segue identifier] isEqualToString:@"privacySegue"])
    {
        TermsViewController *vc = [segue destinationViewController];
        vc.type = 2;
    }
}

-(IBAction)logoutClicked:(id)sender
{
    [[CurrentUserModel sharedModel] logout];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[self.storyboard instantiateViewControllerWithIdentifier:@"RecordingNavVC"];
    appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroNavController"];
}
@end
