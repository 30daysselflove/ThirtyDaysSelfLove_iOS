//
//  AffirmationsCollection.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/8/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "AffirmationsCollection.h"
#import "Collection.h"


static NSString *s_modelClassName = @"Affirmation";

@implementation AffirmationsCollection

+(NSString*)modelClassName
{
    return s_modelClassName;
}

@end
