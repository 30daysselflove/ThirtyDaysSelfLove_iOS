//
//  WebAPI.h
//  Blizzfull for iPhone
//
//  Created by Adam Dougherty on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GET,
    POST,
    DELETE,
    PUT
} httpMethods;

@interface WebAPI : NSObject
{
@private
    NSString * _gateway;
    NSMutableDictionary * _persistentParamters;
    NSString * _alternateGateway;
}


- (void) call: (NSString*) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector resultBlock:(void(^)(bool))resultBlock;
- (void) callAsPost: (NSString*) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector resultBlock:(void(^)(bool))resultBlock;
- (void) call: (NSString *) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector andProvideContext:(id) context resultBlock:(void(^)(bool))resultBlock;
- (void) callAsPost: (NSString*) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector andProvideContext:(id) context resultBlock:(void(^)(bool))resultBlock;
- (void) addPersistentParamter:(NSString *) param;
- (void)useAlternateGateway:(NSString*) altGateway;
- (void)resetAlternateGateway;
- (id) initWithGateway:(NSString *) gatewayURL andPersistentParams:(NSMutableDictionary*) params;
@property (strong) NSString * gateway;

@end
