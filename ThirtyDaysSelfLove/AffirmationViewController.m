//
//  AffirmationViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "AffirmationViewController.h"
#import "AffirmationsCollection.h"
#import "Affirmation.h"
#import "Collection.h"
#import "UIImageView+WebCache.h"

@interface AffirmationViewController ()

@end

@implementation AffirmationViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.wantsFullScreenLayout = true;
    __block AffirmationViewController *me = self;
    self.affirmationLabel.alpha = 0.0;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_affirmations loadWithCallback:^(bool success)
     {
         if(!success)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Woops..." message:@"Could not connect to 30 Days Self Love Network" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return;
         }
         
             if(_affirmations.count)
             {
                 Affirmation *firstModel = (Affirmation*)[_affirmations get:0];
                 
                 me.affirmationLabel.text = firstModel.affirmation;
                 if(firstModel.backgroundImageURL.length == 0)
                 {
                     [me.backgroundImageView setImage:[UIImage imageNamed:@"bg-aspirations.png"]];
                 }
                 else [me.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:firstModel.backgroundImageURL]];
                 
                 [UIView animateWithDuration:1.0
                                       delay: 0.0
                                     options: UIViewAnimationCurveEaseOut
                                  animations:^{
                                      me.affirmationLabel.alpha = 1.0;
                                  }
                                  completion:nil];
             }
         
     }];
    
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _affirmations = [[AffirmationsCollection alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
