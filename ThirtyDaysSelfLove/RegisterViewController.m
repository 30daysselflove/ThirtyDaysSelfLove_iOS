//
//  RegisterViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/9/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "RegisterViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CurrentUserModel.h"
#import "AppDelegate.h"
#import "DBValidator.h"
#import "TermsViewController.h"


@implementation RegisterViewController

-(void)viewDidLoad
{
    UIView * filter = [UIView new];
    filter.frame = self.view.frame;
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.25;
    [self.view insertSubview:filter atIndex:0];
    self.emailField.delegate = self;
    self.fullNameField.delegate = self;
    self.passwordField.delegate = self;
    self.usernameField.delegate = self;

    DBValidationEmailRule * emailRule = [[DBValidationEmailRule alloc] initWithObject:self.emailField keyPath:@"text" failureMessage:@"Invalid Email"];
    [self.emailField addValidationRule:emailRule];

    DBValidationStringLengthRule *passwordLengthRule = [[DBValidationStringLengthRule alloc] initWithObject:self.passwordField keyPath:@"text" minStringLength:6 maxStringLength:64 failureMessage:@"Password must be greater than 6 characters."];
    [self.passwordField addValidationRule:passwordLengthRule];

    DBValidationStringLengthRule *usernameLengthRule = [[DBValidationStringLengthRule alloc] initWithObject:self.usernameField keyPath:@"text" minStringLength:4 maxStringLength:64 failureMessage:@"Nickname must be greater than 4 characters and less than 20."];
    [self.usernameField addValidationRule:usernameLengthRule];
    
    [self.privacyButton setTitle:@"" forState:UIControlStateNormal];
    [self.tosButton setTitle:@"" forState:UIControlStateNormal];
    
}
-(void)dealloc
{
    currentTextField = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    if(!kbHeight)
    {
        CGRect keyboardBounds;
        NSValue *aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
        
        [aValue getValue:&keyboardBounds];
        kbHeight = keyboardBounds.size.height;
    }
    
    [self setViewMovedUp:YES];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    currentTextField = sender;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    
    CGPoint tfPoint = [currentTextField.superview convertPoint:currentTextField.frame.origin toView:nil];
    
    if(movedUp)
    {
        NSLog(@"new point: %f, %f", tfPoint.y,self.view.bounds.size.height - kbHeight);
        if(kbHeight && tfPoint.y + currentTextField.bounds.size.height > self.view.bounds.size.height - kbHeight)
        {
            CGRect rect = self.view.bounds;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3]; // if you want to slide up the view
            
            rect.origin.y += (tfPoint.y + currentTextField.bounds.size.height) - (self.view.bounds.size.height - kbHeight);
            self.view.bounds = rect;
            
            [UIView commitAnimations];
        }
    }
    else
    {
        CGRect rect = self.view.bounds;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        
        rect.origin.y =0;
        self.view.bounds = rect;
        
        [UIView commitAnimations];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"termsRegisterSegue"])
    {
        TermsViewController *vc = [segue destinationViewController];
        vc.type = 1;
    }
    else if ([[segue identifier] isEqualToString:@"privacyRegisterSegue"])
    {
        TermsViewController *vc = [segue destinationViewController];
        vc.type = 2;
    }
    
    
}

-(IBAction)join:(id)sender
{
    
    NSArray *textFields = @[self.emailField, self.passwordField, self.usernameField];
    for (id object in textFields) {
        NSArray * invalidMessages = [object validate];
        if([invalidMessages count])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not yet..." message:[invalidMessages objectAtIndex:0] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            return;
        }
    }

    self.registerButton.enabled = false;
    CurrentUserModel * user = [CurrentUserModel sharedModel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onLogin:) name:@"login" object:user];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onError:) name:@"error" object:user];

    [user registerWithEmail:self.emailField.text username:self.usernameField.text realName:self.fullNameField.text password:self.passwordField.text];
}

-(void)_onError:(NSNotification*)notification
{
    CurrentUserModel * user = [CurrentUserModel sharedModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"error" object:user];
    NSString * message = (NSString*)notification.userInfo;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:message delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    self.registerButton.enabled = true;
}
-(void)_onLogin:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"registerToHome" sender:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.view insertSubview:AppDelegate.bgVideoPlayer atIndex:0];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     
                     NSDictionary<FBGraphUser> *fbUser = result;
                     
                   
                     CurrentUserModel * user = [CurrentUserModel sharedModel];
                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onLogin:) name:@"login" object:user];
                     [user loginWithFacebook:fbUser.objectID withUserData:fbUser];
                 } else {
                     // An error occurred, we need to handle the error
                     // See: https://developers.facebook.com/docs/ios/errors
                 }
             }];
             
             // Retrieve the app delegate
             AppDelegate* appDelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

@end
