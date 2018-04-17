//
//  ResetPasswordViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/9/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "AppDelegate.h"
#import "CurrentUserModel.h"

@implementation ResetPasswordViewController

-(void)viewDidLoad
{
    UIView * filter = [UIView new];
    filter.frame = self.view.frame;
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.25;
    [self.view insertSubview:filter atIndex:0];
    self.emailField.delegate = self;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view insertSubview:AppDelegate.bgVideoPlayer atIndex:0];
}

-(void)resetPasswordClicked:(id)sender
{
    __weak ResetPasswordViewController *me = self;
    self.resetButton.enabled = false;
    self.errorLabel.text = @"";
    [[CurrentUserModel sharedModel] resetPassword:self.emailField.text callback:^(bool success){
        
        if([[CurrentUserModel sharedModel] lastError] && [[[CurrentUserModel sharedModel] lastError] length])
        {
            me.errorLabel.text = [[CurrentUserModel sharedModel] lastError];
        }
        else
        {
            [me performSegueWithIdentifier:@"resetSentSegue" sender:me];
        }
        me.resetButton.enabled = true;
    }];
}

-(IBAction)closeClicked:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
