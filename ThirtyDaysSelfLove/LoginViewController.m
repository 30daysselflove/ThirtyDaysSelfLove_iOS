//
//  LoginViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/8/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "CurrentUserModel.h"
#import "AppDelegate.h"
#import "DBValidationStringLengthRule.h"
#import "DBValidator.h"

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    UIView * filter = [UIView new];
    filter.frame = self.view.frame;
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.25;
    [self.view insertSubview:filter atIndex:0];

    self.identField.delegate = self;
    self.passwordField.delegate = self;

    DBValidationEmailRule * emailRule = [[DBValidationEmailRule alloc] initWithObject:self.identField keyPath:@"text" failureMessage:@"Invalid Login Email"];
    [self.identField addValidationRule:emailRule];

    DBValidationStringLengthRule *passwordLengthRule = [[DBValidationStringLengthRule alloc] initWithObject:self.passwordField keyPath:@"text" minStringLength:6 maxStringLength:64 failureMessage:@"Invalid Password"];
    [self.passwordField addValidationRule:passwordLengthRule];

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return YES;
}


-(IBAction)login:(id)sender
{

    NSArray *textFields = @[self.identField, self.passwordField];
    for (id object in textFields) {
            NSArray * invalidMessages = [object validate];
         if([invalidMessages count])
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not yet..." message:[invalidMessages objectAtIndex:0] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
             [alert show];
             return;
         }
    }

    CurrentUserModel * user = [CurrentUserModel sharedModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onLogin:) name:@"login" object:user];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onError:) name:@"error" object:user];
    [user loginWithIdentifier:self.identField.text andPassword:self.passwordField.text];
    
    self.loginButton.enabled = false;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view insertSubview:AppDelegate.bgVideoPlayer atIndex:0];
}

-(void)_onLogin:(NSNotification*)notification
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[self.storyboard instantiateViewControllerWithIdentifier:@"RecordingNavVC"];
    appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabController"];
    
    //[self performSegueWithIdentifier:@"loginToHome" sender:self];
}

-(void)_onError:(NSNotification*)notification
{
    CurrentUserModel * user = [CurrentUserModel sharedModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"error" object:user];
    NSString * message = (NSString*)notification.userInfo;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:message delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    self.loginButton.enabled = true;
    self.loginWithFacebookButton.enabled = true;
}

-(IBAction)loginWithFacebook:(id)sender
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        
        self.loginWithFacebookButton.enabled = false;
        CurrentUserModel *user = [CurrentUserModel sharedModel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onLogin:) name:@"login" object:user];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onError:) name:@"error" object:user];
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email",@"user_about_me"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}


@end
