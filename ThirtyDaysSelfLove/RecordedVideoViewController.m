//
//  RecordedVideoViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/30/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RecordedVideoViewController.h"
#import "SCRecorder.h"
#import "SCRecordSession.h"
#import  "SCAssetExportSession.h"
#import "SCPlayer.h"
#import "VideoUploadViewController.h"
#import "Video.h"
#import "CurrentUserModel.h"
#import <UIKit/UIKit.h>

@interface RecordedVideoViewController ()
{
    SCVideoPlayerView *_player;
    BOOL keyboardIsShowing;
    CGFloat origCommentViewConstraintY;
}
@end

@implementation RecordedVideoViewController

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    _player = [[SCVideoPlayerView alloc] init];
    
    [self.previewView addSubview:_player];
    //_player.hidden = TRUE;
    _player.frame = self.previewView.bounds;
    self.titleText.delegate = self;
    self.descriptionText.delegate = self;
    
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}


-(void)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_player.player pause];
    _player.player = nil;
    _player = nil;
    currentTextField = nil;
    
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
-(void)viewDidAppear:(BOOL)animated
{
    //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"record session: %@", self.recordSession);
    NSLog(@"record session: %@", _recordSession);
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];

    [_player.player setItemByAsset:_recordSession.assetRepresentingRecordSegments];
    [_player.player play];
    

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_player.player pause];
}

-(void)_processVideoAssets
{
    __block RecordedVideoViewController *me = self;

    [_recordSession mergeRecordSegmentsUsingPreset:AVAssetExportPresetMediumQuality completionHandler:^(NSURL *url, NSError *error) {
        if (error == nil) {
            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil);
            
            if(!me.uploadSwitch.on) return;
            AVAsset *assetToExport = _recordSession.assetRepresentingRecordSegments;
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:assetToExport];
            generator.appliesPreferredTrackTransform=TRUE;
            CMTime videoLength = assetToExport.duration;
            Float64 videoLengthSeconds = CMTimeGetSeconds(videoLength);
            CMTime thumbTime = CMTimeMakeWithSeconds(videoLengthSeconds / 6,30);
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                if (result != AVAssetImageGeneratorSucceeded) {
                    NSLog(@"couldn't generate thumbnail, error:%@", error);
                }
                //Convert CGImage thumbnail to UIImage.
                _thumbImage = [UIImage imageWithCGImage:im];
                
                _uploadVc.videoModel = _newVideo;
                _uploadVc.thumbImage = _thumbImage;
                _uploadVc.videoFileURI = url;
                [_uploadVc startUpload];
                
                return;
                
            };
            
            [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
            
        } else {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [[[UIAlertView alloc] initWithTitle:@"Hmm.." message:@"Video processing was interrupted. Would you like to restart?" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yes", nil] show];
            
        }
    }];
}

-(IBAction)doneClicked:(id)sender
{
    //[_recordSession saveToCameraRoll];
    
    CurrentUserModel * currentUser = [CurrentUserModel sharedModel];
  
    if(self.uploadSwitch.on)
    {
        //NSLog(@"wtf");
        _newVideo = [Video new];
        _newVideo.title = self.titleText.text;
        _newVideo.description = self.descriptionText.text;
        _newVideo.userID = [NSNumber numberWithUnsignedInt:currentUser.id];
        _newVideo.public = [NSNumber numberWithBool:self.privacySwitch.selectedSegmentIndex == 0];
        [self performSegueWithIdentifier:@"UploadVideo" sender:self];
        [_newVideo saveWithCompletionHandler:^(BOOL success){
           
            if(!success)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:@"Could not connect to 30 Days Self Love Network" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
          
            [self _processVideoAssets];
            
        }];
    }
    else
    {
        [self _processVideoAssets];
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
}

// Handle alert form click event
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
            break;
        case 1:
            [self _processVideoAssets];
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[VideoUploadViewController class]]) {
        VideoUploadViewController *uploadVc = segue.destinationViewController;
        
        _uploadVc = uploadVc;
        
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
