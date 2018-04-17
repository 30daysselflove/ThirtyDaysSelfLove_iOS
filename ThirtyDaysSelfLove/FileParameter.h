//
//  FileParameter.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileParameter : NSObject

@property NSString *name;
@property NSData *data;
@property NSString *fileName;
@property NSString *mimeType;

-(id)initWithName:(NSString*) name data:(NSData*) data fileName:(NSString*) fileName;
-(id)initWithName:(NSString*) name data:(NSData*) data fileName:(NSString*) fileName mimeType:(NSString*) mimeType;

@end
