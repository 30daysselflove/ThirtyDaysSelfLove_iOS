//
//  VideosCollection.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/29/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "Collection.h"


typedef enum VideoListContext : NSUInteger {
    VideoListFollowing,
    VideoListEveryone
} VideoListContext;

@interface VideosCollection : Collection


@property VideoListContext videoListContext;
@property NSUInteger contextUserID;

@end
