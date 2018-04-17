//
//  RecordViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/29/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "RecordViewController.h"
#import "SCRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "SCAudioTools.h"
#import "SCRecorderFocusView.h"
#import "SCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCRecordSessionManager.h"
#import "RecordedVideoViewController.h"
#import "CurrentUserModel.h"
#import "RecordSectionNavigationController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface RecordViewController ()
{
    SCRecorder* _recorder;
    SCRecordSession *_recordSession;
}
@property (strong, nonatomic) SCRecorderFocusView *focusView;
@end

@implementation RecordViewController

-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [(RecordSectionNavigationController*)self.navigationController setRecording:true];
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = [SCRecorderTools bestSessionPresetCompatibleWithAllDevices];
    //_recorder.audioEnabled = YES;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
   
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeRecordSessionLazily = YES;
    self.stopButton.hidden = true;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    self.focusView.userInteractionEnabled = false;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);
        
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
    self.recordIndicator.hidden = true;
}

-(IBAction)recordTapped:(id)sender
{
    self.recordButton.hidden = true;
    self.reverseCamera.hidden = true;
    self.librarySelectorButton.hidden = true;
    self.stopButton.hidden = false;
    self.recordIndicator.hidden = false;
    self.recordIndicator.alpha = 1;
    
    //[_recorder.recordSession removeAllSegments];
    NSLog(@"began session: :%i", _recorder.recordSession.recordSegmentBegan);
    __block RecordViewController *me = self;
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         me.recordIndicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    [_recorder record];
}

-(IBAction)stopTapped:(id)sender
{
    [self.recordIndicator.layer removeAllAnimations];
    
    self.recordIndicator.hidden = true;
    self.recordButton.hidden = false;
    self.stopButton.hidden = true;
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
        [self finishSession:recordSession];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        _recorder.recordSession = session;
        
        [self.view insertSubview:self.previewView atIndex:0];
        [_recorder switchCaptureDevices];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RecordedVideoViewController class]]) {
        RecordedVideoViewController *videoPlayer = segue.destinationViewController;
        NSLog(@"record session prep :%@", _recordSession );
        videoPlayer.recordSession = _recordSession;
        
    }
}

- (void)finishSession:(SCRecordSession *)recordSession {
    
    _recordSession = recordSession;
    
    __block UIViewController * me = self;
    [_recorder pause:^{
        [_recordSession endRecordSegment:^(NSInteger segmentIndex, NSError *error) {
            [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
            
            [(RecordSectionNavigationController*)me.navigationController setRecording:false];
            UIViewController *portraitViewController = [[UIViewController alloc] init];
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:portraitViewController];
            
                [me presentViewController:nc animated:false completion:nil];
                [me dismissViewControllerAnimated:false completion:^(void){
                [me performSegueWithIdentifier:@"RecordingComplete" sender:me];
 
            }];
            
            
        }];
        
    }];
    
    return;
    
}

- (void)showVideo {
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession {
    [self finishSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginRecordSegment:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    NSLog(@"End record segment %d at %@: %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
}



- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    //[self updateTimeRecordedLabel];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:true];
    
    [self prepareCamera];
    
    //self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunningSession];
    [_recorder focusCenter];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:false];
    [_recorder endRunningSession];
}

-(IBAction)reverseTapped:(id)sender
{
    [_recorder switchCaptureDevices];
}

-(IBAction)closeTapped:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}
-(IBAction)librarySelectorTapped:(id)sender
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    ipc.delegate = self;
    ipc.editing = NO;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
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
