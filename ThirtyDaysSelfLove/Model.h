//
//  Model.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef void (^SaveCompletionHandler)(BOOL success);
@class WebAPI;
@interface Model : JSONModel
{
    @protected
        WebAPI *_webAPI;
        BOOL _updateChangedKeys;
    @private
        unsigned int _id;
        NSMutableDictionary *_changedKeys;
    
    
}


+(NSString*)basePath;
+(NSString*)modelName;
-(id) initWithID:(int) modelID;
+(void)setBasePath:(NSString*) url;
+(void)setModelName:(NSString*) url;
-(void)load;
-(void)loadWithCallback:(void(^)(bool))callback;
-(void)save;
-(void)revert;
-(void)saveWithCompletionHandler:(void (^)(BOOL success))completionHandler;
-(void)destroy;
-(void)uploadFileData:(NSData*) data toKey:(NSString*) key usingFileName:(NSString*) name andMimeType:(NSString*)mimeType result:(void(^)(bool))resultBlock;
-(NSDictionary*)_processResponse:(id) data : (NSNumber*) success : (NSString*) action;

@property (nonatomic) unsigned int id;
@property (assign) BOOL loaded;
@property (copy) SaveCompletionHandler saveCompletionHandler;

@end
