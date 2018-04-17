//
//  UserModel.h
//  Blizzfull for iPad
//
//  Created by Adam Dougherty on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@class WebAPI;

@interface CurrentUserModel : JSONModel
{
    @private
    unsigned int _id;
    WebAPI * _webAPI;
    
}

+(CurrentUserModel *) resetSharedModel;
+(CurrentUserModel *) sharedModel;
-(void) registerWithEmail:(NSString*)email username:(NSString*)username realName:(NSString*)realName password:(NSString*)password;
-(void) loginWithIdentifier:(NSString*) identifier andPassword:(NSString*) password;
-(void) loginWithFacebook:(NSString*)userID withUserData:(NSDictionary*)userData;
-(void) loginWithFacebook;
-(void) resync;
-(void)setData:(NSDictionary*)data;
-(void)logout;
-(void)resetPassword:(NSString*)email callback:(void(^)(bool))callback;
-(void)commitQueuedRemoteActions;
@property (assign) unsigned int id;
@property (assign) BOOL loggedIn;
@property NSMutableArray *queuedRemoteActions;
@property NSMutableArray *queuedLocalActions;
@property NSString *lastError;

@end
