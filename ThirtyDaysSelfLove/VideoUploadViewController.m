//
//  TKViewController.m
//  TUSKit
//
//  Created by Michael Avila on 08/10/2014.
//  Copyright (c) 2014 Michael Avila. All rights reserved.
//

#import "VideoUploadViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "TUSKit.h"
#import "ShareKit.h"
#import "TUSResumableUpload.h"
#import "CurrentUserModel.h"
#import "NSString+MD5.h"

#define THUMB_UPLOAD_PERCENTAGE 10.0
#define MAX_RETRIES 4
#define INVITE_HASH_SECRET @"30bjd8891bb!j38abMiiC"

static NSString* const UPLOAD_ENDPOINT = @"http://api.30daysselflove.com/upload";

@interface VideoUploadViewController ()

@property (strong,nonatomic) ALAssetsLibrary *assetLibrary;

@end

@implementation VideoUploadViewController

@synthesize videoFileURI;
@synthesize percentageLabel;

-(IBAction)share:(id)sender
{
    // Create the item to share (in this example, a url)
    NSUInteger videoID = self.videoModel.id;
    NSString *videoIDString = [NSString stringWithFormat:@"%lu-%@", (unsigned long)videoID, INVITE_HASH_SECRET];
    NSString *videoIDHash = [videoIDString md5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://join.30daysselflove.com/video/%lu/%@",
                    (unsigned
    long)videoID,
                                                                 videoIDHash]];
    SHKItem *item = [SHKItem URL:url title:@"I'm sharing a video of my personal journey" contentType:SHKURLContentTypeWebpage];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self];
    
    // Display the action sheet
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

-(void)viewDidLoad
{
    self.shareButton.alpha = 0.0;
    self.doneButton.alpha = 0.0;
    self.percentageLabel.text = @"10%";
    self.progressIndicator.percentage = 10;
}

-(void)startUpload
{
    __weak VideoUploadViewController * me = self;
    
    NSData *imageData = UIImageJPEGRepresentation(self.thumbImage, 0.95);
    _retries = 0;
    [self.videoModel uploadFileData:imageData toKey:@"thumbImageURL" usingFileName:@"thumbImage.jpg" andMimeType:@"image/jpeg" result:^(bool success)
     {
         NSLog(@"being video upload");
         if(!success)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:@"Could not connect to 30 Days Self Love Network" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return;
         }
         long thumbPercentage = THUMB_UPLOAD_PERCENTAGE;
         me.percentageLabel.text = [NSString stringWithFormat:@"%ld%%", thumbPercentage];
         me.progressIndicator.percentage = thumbPercentage;
         NSURL *assetUrl = me.videoFileURI;
         
         NSString *fingerprint = [assetUrl absoluteString];
         TUSData *uploadData = [[TUSData alloc] initWithData:[NSData dataWithContentsOfURL:assetUrl]];
         _currentUpload = [[TUSResumableUpload alloc] initWithURL:[NSString stringWithFormat:@"%@",UPLOAD_ENDPOINT] data:uploadData fingerprint:fingerprint];
         _currentUpload.customHeaders = @{@"videoID" : [NSString stringWithFormat:@"%u", me.videoModel.id]};
         _currentUpload.progressBlock = ^(NSInteger bytesWritten, NSInteger bytesTotal){
             // Update your progress bar here

             if(bytesWritten == 0 || bytesTotal == 0) return;
             long thumbPercentage = THUMB_UPLOAD_PERCENTAGE;
             long percentage = MIN(thumbPercentage + (long)(lroundf((float)bytesWritten / (float)bytesTotal * 100.0f)), 100.0f);
             me.progressIndicator.percentage = percentage;
             me.percentageLabel.text = [NSString stringWithFormat:@"%ld%%", percentage];
         };

         _currentUpload.resultBlock = ^(NSURL* fileURL){
             // Use the upload url
             
             me.percentageLabel.text = @"100%";
             me.progressIndicator.percentage = 100.0;
             [UIView animateWithDuration:1.0
                                   delay: 0.0
                                 options: UIViewAnimationOptionCurveEaseOut
                              animations:^{
                                  
                                  me.doneButton.alpha = 1.0;
                                  me.shareButton.alpha = 1.0;
                              }
                              completion:nil];
         };

         _currentUpload.failureBlock = ^(NSError* error){
             // Handle the error
             NSLog(@"error: %@", error);
             VideoUploadViewController *strongMe = me;
             strongMe->_retries++;
             if(strongMe->_retries < MAX_RETRIES)
             {
                 [strongMe->_currentUpload start];
             }
             else
             {
                 UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Woops..."
                                                                  message:@"We coudln't finish uploading your video. Would you like try resuming? Your video is still safe and sound in your camera roll."
                                                                 delegate:strongMe
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles: nil];
                 [alert addButtonWithTitle:@"Retry"];
                 [alert show];
                 strongMe->_retries = 0;
             }
         };
         
         [_currentUpload start];

     }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
    else if(buttonIndex == 1)
    {
        [_currentUpload start];
    }
}

-(IBAction)doneClicked:(id)sender
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
}



@end
