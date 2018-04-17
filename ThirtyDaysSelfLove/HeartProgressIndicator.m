//
//  HeartLoader.m
//  HeartFillLoader
//
//  Created by Adam Dougherty on 12/11/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "HeartProgressIndicator.h"

@implementation HeartProgressIndicator


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    inner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart-fill"]];
    outer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart-outline"]];
    
    CGRect innerFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect outerFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    inner.frame = innerFrame;
    outer.frame = outerFrame;
    
    _maxHeight = inner.bounds.size.height;
    _maxWidth = inner.bounds.size.width;
    CGRect innerBounds = inner.bounds;
    innerBounds.size.width = 0;
    innerBounds.size.height = 0;
    inner.bounds = innerBounds;
    self.userInteractionEnabled = false;
    
    self.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.0];
    [self addSubview:inner];
    [self addSubview:outer];
    return self;
}

-(void)toggleActivityMode
{
    CGRect innerBounds = inner.bounds;
    innerBounds.size.width = 0;
    innerBounds.size.height = 0;
    inner.bounds = innerBounds;
    self.alpha = 1;
    
    [UIView animateWithDuration:10
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect f = inner.bounds;
                         f.size.width = _maxWidth;
                         f.size.height = _maxHeight;
                         inner.bounds = f;
                     }
                     completion:^(BOOL finished)
     {
         if(finished)
         {
            [self endActivityMode];
         }
     }];
}

-(void)endActivityMode
{
    CALayer * layer = inner.layer.presentationLayer;
    [inner.layer removeAllAnimations];
    inner.layer.bounds = layer.bounds;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect f = inner.bounds;
                         f.size.width = _maxWidth;
                         f.size.height = _maxHeight;
                         inner.bounds = f;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.4
                                               delay:0
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.alpha = 0;
                                          }
                                          completion:nil];
                     }];
}
-(void)setPercentage:(float)percentage
{
    _percentage = percentage;
    CALayer * layer = inner.layer.presentationLayer;
    [inner.layer removeAllAnimations];
    inner.layer.bounds = layer.bounds;
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect f = inner.bounds;
                         f.size.width = _maxWidth * (float)(_percentage / (float)100);
                         f.size.height = _maxHeight * (float)(_percentage / (float)100);
                         inner.bounds = f;
                     }
                     completion:^(BOOL finished){
                        
                     }];

}

-(float)percentage
{
    return _percentage;
}

-(void)fadeOut
{
    
}
@end
