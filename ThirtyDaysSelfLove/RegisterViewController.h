//
//  RegisterViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/9/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate>
{
    UITextField *currentTextField;
    CGFloat kbHeight;
}
-(IBAction)loginWithFacebook:(id)sender;
-(IBAction)join:(id)sender;
-(IBAction)tosButtonClicked:(id)sender;
-(IBAction)privacyButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel* agreementLabel;
@property (weak, nonatomic) IBOutlet UIButton* tosButton;
@property (weak, nonatomic) IBOutlet UIButton* privacyButton;




@end
