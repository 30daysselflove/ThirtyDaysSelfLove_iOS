//
//  HeartLoader.h
//  HeartFillLoader
//
//  Created by Adam Dougherty on 12/11/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartProgressIndicator : UIView
{
    UIImageView * inner;
    UIImageView * outer;
    float _percentage;
    CGFloat _maxWidth;
    CGFloat _maxHeight;
    
}

-(void)fadeOut;
-(void)toggleActivityMode;
-(void)endActivityMode;
@property float percentage;

@end
