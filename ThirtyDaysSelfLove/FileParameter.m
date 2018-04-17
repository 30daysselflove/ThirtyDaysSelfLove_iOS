//
//  FileParameter.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "FileParameter.h"

@implementation FileParameter

-(id)initWithName:(NSString*) name data:(NSData*) data fileName:(NSString*) fileName
{
    self = [super init];
    self.name = name;
    self.data = data;
    self.fileName = fileName;
    return self;
}

-(id)initWithName:(NSString*) name data:(NSData*) data fileName:(NSString*) fileName mimeType:(NSString*) mimeType;
{
    self = [super init];
    self.name = name;
    self.data = data;
    self.fileName = fileName;
    self.mimeType = mimeType;
    return self;
}

@end
