//
//  NSString+NSString_FrameToQueryString.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/7/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "NSString+NSString_FrameToQueryString.h"
#include <CoreGraphics/CGGeometry.h>

@implementation NSString (NSString_FrameToQueryString)

+(NSString*)queryStringUsingFrame:(CGRect)frame
{
    return [NSString stringWithFormat:@"w=%u&h=%u", (uint) CGRectGetWidth(frame), (uint) CGRectGetHeight(frame)];
}

@end
