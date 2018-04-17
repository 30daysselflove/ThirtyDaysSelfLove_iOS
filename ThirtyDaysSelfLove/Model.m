//
//  Model.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 9/26/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//



#import <objc/runtime.h>
#import "Model.h"
#import "WebAPI.h"
#import "FileParameter.h"

static NSString *s_basePath;
static NSString *s_modelName;

@implementation Model

@synthesize id = _id;
@synthesize loaded;



-(id) init
{
    self = [super init];
    _webAPI = [[WebAPI alloc] initWithGateway:[[self class] basePath] andPersistentParams:nil];

    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (size_t i = 0; i < count; ++i) {
        NSString *key = [NSString stringWithCString:property_getName(properties[i])];
        if([key isEqualToString:@"id"] || [key isEqualToString:@"loaded"]) continue;
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld context:NULL];
    }
    free(properties);
    _changedKeys = [NSMutableDictionary new];
    _updateChangedKeys = true;
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(!_updateChangedKeys) return;
    id oldVal = change[@"old"];
    [_changedKeys setObject:oldVal forKey:keyPath];
}

-(id) initWithID:(int) modelID
{
    _id = modelID;
    return [self init];
}

+(NSString*)basePath
{
    return s_basePath;
}

+(void)setBasePath:(NSString*) url
{
    s_basePath = url;
}

+(NSString*)modelName
{
    return s_modelName;
}

+(void)setModelName:(NSString*) name
{
    s_modelName = name;
}

-(void)load
{
    [self loadWithCallback:nil];
}

//Sync functions
-(void)loadWithCallback:(void(^)(bool))callback
{
    [_webAPI call:[NSString stringWithFormat:@"%@s/%i", [[self class] modelName], _id] usingParameters:nil andNotifyObject:self withSelector:@selector(_onLoad::) resultBlock:callback];
}

-(void)saveWithCompletionHandler:(SaveCompletionHandler) completionHandler
{
    [self save];
    
    self.saveCompletionHandler = completionHandler;
}

-(void)save
{
    NSDictionary *props = [self toDictionary];
    NSMutableDictionary *propsToExport = [NSMutableDictionary new];
    for (id key in props) {
        
        if(![key isEqual:@"id"] && ![key isEqual:@"masterForObs_"] && ![key isEqual:@"loaded"] && [_changedKeys valueForKey:key] != nil)
        {
            [propsToExport setObject:props[key] forKey:key];
        }
    }
    
    if(_id)
    {
        //Update
        [_webAPI callAsPost:[NSString stringWithFormat:@"%@s/%i", [[self class] modelName], _id] usingParameters:propsToExport andNotifyObject:self withSelector:@selector(_onUpdate::) resultBlock:nil];
    }
    else
    {
        //Create
        [_webAPI callAsPost:[NSString stringWithFormat:@"%@s", [[self class] modelName]] usingParameters:propsToExport andNotifyObject:self withSelector:@selector(_onCreate::) resultBlock:nil];
    }
    
}

-(void)destroy
{
    [_webAPI callAsPost:[NSString stringWithFormat:@"%@s/%i/delete", [[self class] modelName], _id] usingParameters:nil andNotifyObject:self withSelector:@selector(_onDestroy::) resultBlock:nil];
}

/**
 Processes errors in a single centralized method and ensures that the data returned is a NSDictionary
 If it is not a NSDictionary, returns nil;
 */
-(NSDictionary*)_processResponse:(id) data : (NSNumber*) success : (NSString*) action
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
        if([data isKindOfClass:[NSDictionary class]])
        {
            return data;
        }
        return data;
    }
}

-(void)_onLoad:(id) data : (NSNumber*) success
{
    if([self _processResponse:data:success:@"load"])
    {
        _updateChangedKeys = false;
        [self mergeFromDictionary:data useKeyMapping:false];
        _updateChangedKeys = true;
        self.loaded = true;
    }
}

-(void)_onUpdate:(id) data : (NSNumber*) success
{
    if([self _processResponse:data:success:@"update"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updated" object:self userInfo:data];
        if(self.saveCompletionHandler) self.saveCompletionHandler([success boolValue]);
    }
}

-(void)_onCreate:(id) data : (NSNumber*) success
{
    //Mainly used to merge the new id onto the model
    if([self _processResponse:data:success:@"create"])
    {
        _updateChangedKeys = false;
        self.id = [(NSNumber*)data intValue];
        _updateChangedKeys = true;
        self.loaded = true;
        if(self.saveCompletionHandler) self.saveCompletionHandler([success boolValue]);
    }
}

-(void)_onDestroy:(id) data : (NSNumber*) success
{
    if([self _processResponse:data:success:@"destroy"])
    {
        self.id = 0;
    }
}

-(void)revert
{
    _updateChangedKeys = false;
    [self mergeFromDictionary:_changedKeys useKeyMapping:false];
    _updateChangedKeys = true;
}

-(void)uploadFileData:(NSData*) data toKey:(NSString*) key usingFileName:(NSString*) name andMimeType:(NSString*)mimeType result:(void(^)(bool))resultBlock
{
    FileParameter *fileParam = [[FileParameter alloc] initWithName:key data:data fileName:name mimeType:mimeType];
 
    NSDictionary *params = [NSDictionary dictionaryWithObject:fileParam forKey:key];
    [_webAPI callAsPost:[NSString stringWithFormat:@"%@s/%i/file", [[self class] modelName], _id] usingParameters:params andNotifyObject:self withSelector:@selector(_onUploadFileData::) resultBlock:resultBlock];
}

-(void)_onUploadFileData:(id) data : (NSNumber*) success
{
    if([self _processResponse:data:success:@"uploadFileData"])
    {
        
    }
}

- (void)dealloc
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (size_t i = 0; i < count; ++i) {
        NSString *key = [NSString stringWithCString:property_getName(properties[i])];
        [self removeObserver:self forKeyPath:key];
    }
    free(properties);
}
@end
