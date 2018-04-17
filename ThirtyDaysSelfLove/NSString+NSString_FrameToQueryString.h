//
//  NSString+NSString_FrameToQueryString.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/7/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>

@interface NSString (NSString_FrameToQueryString)
+(NSString*)queryStringUsingFrame:(CGRect)frame;

@end
