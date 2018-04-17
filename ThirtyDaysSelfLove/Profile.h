//
//  Video.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/27/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "Model.h"

@class VideosCollection;

@interface Profile : Model

@property VideosCollection *videos;
@property NSString *profileHeader;
@property NSNumber *userID;
@property NSString *username;
@property NSString *realName;
@property NSNumber *following;

-(void)followWithCallback:(void(^)(bool))callback;

@end
