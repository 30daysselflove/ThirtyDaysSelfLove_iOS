//
//  AffirmationViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AffirmationsCollection;

@interface AffirmationViewController : UIViewController
{
    AffirmationsCollection *_affirmations;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *affirmationLabel;

@end
