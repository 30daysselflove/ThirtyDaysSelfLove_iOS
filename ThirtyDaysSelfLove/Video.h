//
//  Video.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/27/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "Model.h"

@interface Video : Model


-(void)postComment:(NSString*) comment withCallback:(void(^)(bool))callback;
-(void)removeComment:(NSUInteger)commentID withCallback:(void(^)(bool))callback;
@property NSString *title;
@property NSString *description;
@property NSString *mediaURL;
@property NSString *thumbImageURL;
@property NSString *uploadDate;
@property NSNumber *supports;
@property NSNumber *reports;
@property NSNumber *userID;
@property NSNumber *newcomments;
@property NSString *username;
@property NSNumber *public;
@property NSMutableArray *comments;






@end
