//
//  VideosCollection.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/29/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "VideosCollection.h"
#import "WebAPI.h"
#import "Collection.h"
#import "Model.h"



static NSString *s_modelClassName = @"Video";

@implementation VideosCollection


+(NSString*)modelClassName
{
    return s_modelClassName;
}

-(VideoListContext)videoListContext
{
    NSNumber * videoListContextNumber = [self.filters valueForKey:@"videoListContext"];
    
    return [videoListContextNumber unsignedIntegerValue];
}

-(void)setVideoListContext:(VideoListContext)videoListContext
{
    NSNumber * videoListContextNumber = [NSNumber numberWithUnsignedInteger:videoListContext];
    [self.filters setObject:videoListContextNumber forKey:@"videoListContext"];
}

-(NSUInteger)contextUserID
{
    NSNumber * userID = [self.filters valueForKey:@"contextUserID"];
    
    return [userID unsignedIntegerValue];
}

-(void)setContextUserID:(NSUInteger)contextUserID
{
    NSNumber * userID = [NSNumber numberWithUnsignedInteger:contextUserID];
    [self.filters setObject:userID forKey:@"contextUserID"];
}
@end
