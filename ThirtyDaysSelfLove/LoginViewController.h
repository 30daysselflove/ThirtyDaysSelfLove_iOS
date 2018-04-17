//
//  LoginViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/8/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
{
}

-(IBAction)loginWithFacebook:(id)sender;
-(IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *identField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebookButton;


@end
