//
//  Model.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"


@class WebAPI;
@class Model;

@interface Collection : NSObject<NSFastEnumeration>
{
    @protected
        WebAPI *_webAPI;
        Class _modelClass;
        NSMutableArray *_collectionArray;
        NSUInteger _cursor;
}


+(NSString*)basePath;
+(NSString*)modelClassName;
+(void)setBasePath:(NSString*) url;
-(id)initWithArray:(NSArray*)array;
-(void)loadMoreWithCallback:(void(^)(bool))callback;
-(void)loadWithCallback:(void(^)(bool))callback;
-(void)load;
-(void)removeAll;
-(void)remove:(NSUInteger) index;
-(Model*)get:(NSUInteger) index;

-(void)_onLoad:(NSArray*) data : (NSNumber*)success;

@property (readonly) NSUInteger count;
@property (assign) BOOL loaded;
@property NSMutableDictionary *filters;
@property (weak, nonatomic) NSArray * mostRecentlyLoadedModels;

@end
