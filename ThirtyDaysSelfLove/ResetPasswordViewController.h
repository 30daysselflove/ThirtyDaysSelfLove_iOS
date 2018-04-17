//
//  ResetPasswordViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/9/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;;

-(IBAction)resetPasswordClicked:(id)sender;

@end
