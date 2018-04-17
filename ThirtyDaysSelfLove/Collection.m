//
//  Model.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "Collection.h"
#import "WebAPI.h"
#import "Model.h"


static NSString *s_basePath = @"http://api.30daysselflove.com/mcs";
static NSString *s_modelClassName;

@implementation Collection

@synthesize loaded;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
{
    return [_collectionArray countByEnumeratingWithState:state objects:buffer count:len];
}

-(id) init
{
    self = [super init];
    _webAPI = [[WebAPI alloc] initWithGateway:[[self class] basePath] andPersistentParams:nil];
    _modelClass = NSClassFromString([[self class] modelClassName]);
    _collectionArray = [NSMutableArray new];
    self.filters = [NSMutableDictionary new];
    return self;
}

-(id)initWithArray:(NSArray*)array
{
    self = [super init];
    _webAPI = [[WebAPI alloc] initWithGateway:[[self class] basePath] andPersistentParams:nil];
    _modelClass = NSClassFromString([[self class] modelClassName]);
    _collectionArray = [NSMutableArray new];
    self.filters = [NSMutableDictionary new];
    [self _convertModels:array];
    return self;
}

-(void)removeAll
{
    [_collectionArray removeAllObjects];
}

+(NSString*)basePath
{
    return s_basePath;
}

+(void)setBasePath:(NSString*) url
{
    s_basePath = url;
}

+(NSString*)modelClassName
{
    return s_modelClassName;
}

-(NSUInteger)count
{
    return [_collectionArray count];
}

-(void)add:(Model*) model
{
    if(!model.id) [model save]; //Implicitly create (save) the model before adding it to the collection
    [_collectionArray addObject:model];
}

-(void)remove:(NSUInteger) index
{
    [_collectionArray removeObjectAtIndex:index];
}

-(Model*)get:(NSUInteger) index
{
    return [_collectionArray objectAtIndex:index];
}

//Sync functions
-(void)load
{
    [self loadWithCallback:nil];
}

//Sync functions
-(void)loadWithCallback:(void(^)(bool))callback
{
    _cursor = 0;
    self.mostRecentlyLoadedModels = nil;
    [self.filters removeObjectForKey:@"cursor"];
    [_collectionArray removeAllObjects];
    self.loaded = false;
    [_webAPI call:[NSString stringWithFormat:@"%@s", [_modelClass modelName]] usingParameters:self.filters andNotifyObject:self withSelector:@selector(_onLoad::) resultBlock:callback];
}

//Sync functions
-(void)loadMoreWithCallback:(void(^)(bool))callback
{
    self.mostRecentlyLoadedModels = nil;
    if(_cursor) [self.filters setObject:[NSNumber numberWithUnsignedInteger:_cursor] forKey:@"cursor"];
    [_webAPI call:[NSString stringWithFormat:@"%@s", [_modelClass modelName]] usingParameters:self.filters andNotifyObject:self withSelector:@selector(_onLoad::) resultBlock:callback];
}

/**
 Processes errors in a single centralized method and ensures that the data returned is a NSDictionary
 If it is not a NSDictionary, returns nil;
 */
-(NSArray*)_processResponse:(id) data : (NSNumber*) success : (NSString*) action
{
    if(![success boolValue])
    {
        NSString * message;
        if([data isKindOfClass:[NSDictionary class]])
        {
            message = [(NSDictionary*)data objectForKey:@"message"];
        }
        else message = data;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:self userInfo:message];
        return nil;

    }
    else
    {
        if([data isKindOfClass:[NSArray class]])
        {
            return data;
        }
        return nil;
    }
}

-(void)_convertModels:(NSArray*)models
{
    for(id object in models)
    {
        Model *model = [[_modelClass alloc] init];
        [model mergeFromDictionary:object useKeyMapping:false];
        [_collectionArray addObject:model];
        if(_cursor == 0 || model.id < _cursor) _cursor = model.id;
    }
    
    self.mostRecentlyLoadedModels = models;
}

-(void)_onLoad:(NSArray*) data : (NSNumber*)success
{
    if([self _processResponse:data :success :@"load"])
    {
        [self _convertModels:data];
        self.loaded = true;
    }
}


@end
