//
//  DatePickerViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 11/30/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "DatePickerViewController.h"
#import "SettingsViewController.h"

@implementation DatePickerViewController

-(IBAction)doneClicked:(id)sender
{
    NSDate * dt = [self.datePicker date];
    [self.settingsVc recordingDateSet:dt];
}
@end
