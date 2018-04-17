//
//  Video.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/27/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "Profile.h"
#import "WebAPI.h"
#import "VideosCollection.h"


static NSString *s_modelName = @"profile";
static NSString *s_basePath = @"http://api.30daysselflove.com";

@implementation Profile


+(NSString*)modelName
{
    return s_modelName;
}

+(NSString*)basePath
{
    return s_basePath;
}

-(void)followWithCallback:(void(^)(bool))callback
{
    NSString * callPath = [NSString stringWithFormat:@"profiles/followOrUnfollow/%u", self.id];
    [_webAPI callAsPost:callPath usingParameters:nil andNotifyObject:self withSelector:@selector(_onFollow::) andProvideContext:nil resultBlock:callback];
}

-(void)_onFollow:(id)data : (NSNumber*)success
{
    if(success)
    {
        self.following = [data objectForKey:@"following"];
    }
}
-(void)_onLoad:(id) data : (NSNumber*) success
{
    if([super _processResponse:data:success:@"load"])
    {
        _updateChangedKeys = false;
        
        NSArray * videos = data[@"videos"];
        [(NSMutableDictionary*)data removeObjectForKey:@"videos"];
        [self mergeFromDictionary:data useKeyMapping:false];
        self.videos = [[VideosCollection alloc] initWithArray:videos];
        _updateChangedKeys = true;
        self.loaded = true;
    }
}

@end
