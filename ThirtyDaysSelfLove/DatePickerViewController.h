//
//  DatePickerViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 11/30/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface DatePickerViewController : UIViewController

-(IBAction)doneClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@property (weak, nonatomic) SettingsViewController *settingsVc;

@end
