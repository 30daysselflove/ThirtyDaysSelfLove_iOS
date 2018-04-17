//
//  Video.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/27/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "Video.h"
#import "WebAPI.h"


static NSString *s_modelName = @"video";

@implementation Video


@synthesize description;
@synthesize title;


+(NSString*)modelName
{
    return s_modelName;
}

-(void)postComment:(NSString*) comment withCallback:(void(^)(bool))callback
{
    
    NSString * callPath = [NSString stringWithFormat:@"video-comments/"];
    [_webAPI callAsPost:callPath usingParameters:@{@"videoID":[NSNumber numberWithInteger:self.id], @"comment" : comment} andNotifyObject:self withSelector:@selector(_onPostComment::) andProvideContext:nil resultBlock:callback];
}

-(void)_onPostComment:(id) data : (NSNumber*) success
{
    if(success)
    {
        [self.comments addObject:data];
    }
}

-(void)removeComment:(NSUInteger)commentID withCallback:(void(^)(bool))callback
{
    NSString * callPath = [NSString stringWithFormat:@"video-comments/%lu/delete", (unsigned long)commentID];
    [_webAPI callAsPost:callPath usingParameters:nil andNotifyObject:self withSelector:@selector(_onRemoveComment::) andProvideContext:[NSNumber numberWithUnsignedLong:commentID] resultBlock:callback];
}

-(void)_onRemoveComment:(id)data : (NSNumber*)success
{
    if(success)
    {
        NSNumber * idNumber = [data objectForKey:@"id"];
        [self.comments enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                       if([[(NSDictionary*)object objectForKey:@"id"] integerValue] == [idNumber integerValue])
            {
                *stop = YES;
                [self.comments removeObjectAtIndex:idx];
            }
        }];
    }
}

@end
