//
//  UserModel.m
//  Blizzfull for iPad
//
//  Created by Adam Dougherty on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentUserModel.h"
#import "WebAPI.h"
#import "RNEncryptor.h"
#import <FacebookSDK/FacebookSDK.h>

static CurrentUserModel * staticInstance = nil;

static NSString * const userManagerGateway = @"http://api.30daysselflove.com";
@implementation CurrentUserModel

@synthesize loggedIn, id;

+ (CurrentUserModel  *)sharedModel
{
    @synchronized(self)
    {
        if(!staticInstance)
        {
            staticInstance = [[CurrentUserModel alloc] init];
            staticInstance.queuedLocalActions = [[NSMutableArray alloc] init];
            staticInstance.queuedRemoteActions = [[NSMutableArray alloc] init];

        }
        return staticInstance;

    }
}

+(CurrentUserModel *) resetSharedModel
{
    @synchronized(self)
    {
        staticInstance = [[CurrentUserModel alloc] init];
        return staticInstance;
    }
}

-(void) reloadUserData
{
    [_webAPI call:@"loadUser" usingParameters:nil andNotifyObject:self withSelector:@selector(onUserLoad:) resultBlock:nil];
}

//Resyncs the user with the backend user model. Primarily used to resync a user when they reopen an app which has retained a session cookie. Should always be called in the bootstrap function. 
-(void) resync
{
    /*NSHTTPCookie *cookie;
    NSURL * cookieURL = [NSURL URLWithString:blizzfullCookieDomain];
    NSArray *blizzfullCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:cookieURL];
    for (cookie in blizzfullCookies) {
        if([cookie.name isEqualToString:@"PHPSESSID"])
        {
            [self reloadUserData];
        }
    }*/
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

-(void)_onLogin:(id) data : (NSNumber*) success
{

        if([self _processResponse:data:success:@"load"])
        {
            if([data isKindOfClass:[NSString class]])
            {
                NSString *message = (NSString*) data;
                if([message isEqualToString:@"Externally Registered"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:self userInfo:@"This email was used to login or register externally through Facebook. You should try using Facebook again."];
                    return;
                }
                else if([message isEqualToString:@"Incorrect email/password"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:self userInfo:message];
                    
                }
                return;
            }
            [self mergeFromDictionary:[data objectForKey:@"user"] useKeyMapping:false];
            self.loggedIn = true;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:self userInfo:data];
            [self commitQueuedRemoteActions];
        }
   
}

-(void) registerWithEmail:(NSString*)email username:(NSString*)username realName:(NSString*)realName password:(NSString*)password
{
    [_webAPI callAsPost:@"usermanager/create" usingParameters:@{@"email" : email, @"password" : password, @"realName" : realName, @"username" : username} andNotifyObject:self withSelector:@selector(_onRegister::) resultBlock:nil];
}

-(void) loginWithIdentifier:(NSString*) identifier andPassword:(NSString*) password
{
  
    [_webAPI callAsPost:@"login" usingParameters:@{@"email" : identifier, @"password" : password} andNotifyObject:self withSelector:@selector(_onLogin::) resultBlock:nil];
    
}

-(void) loginWithFacebook
{
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary<FBGraphUser> *fbUser = result;
            CurrentUserModel * user = [CurrentUserModel sharedModel];
          
            [user loginWithFacebook:fbUser.objectID withUserData:fbUser];
        } else {
           [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:self userInfo:error.description];
        }
    }];
}

-(void) loginWithFacebook:(NSString*)userID withUserData:(NSDictionary*)userData
{
  
    NSData *data = [userID dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:@"j2ndB2928fj#n92LqiENdWn83NMS83)@mnsDNbus@"
                                               error:&error];
    NSString * base64String = [encryptedData base64Encoding];
    NSError *jsonError;
    
    NSMutableDictionary * userDataMutable = [NSMutableDictionary dictionaryWithDictionary:userData];
    NSNumber * unixTs = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]];
    [userDataMutable setObject:unixTs forKey:@"ts"];
    NSData *userDataJsonData = [NSJSONSerialization dataWithJSONObject:userDataMutable options:0 error:&jsonError];
    
    NSError *errorEncryptedUserData;
    NSData *encryptedUserData = [RNEncryptor encryptData:userDataJsonData
                                        withSettings:kRNCryptorAES256Settings
                                            password:@"j2ndB2928fj#n92LqiENdWn83NMS83)@mnsDNbus@"
                                               error:&errorEncryptedUserData];
    NSString * base64StringUserData = [encryptedUserData base64Encoding];
    
    NSString *userDataJson = [[NSString alloc] initWithData:userDataJsonData encoding:NSUTF8StringEncoding];
    
    
    [_webAPI callAsPost:@"login/facebookLogin" usingParameters:@{@"d" : base64String, @"userData" : base64StringUserData} andNotifyObject:self withSelector:@selector(_onFacebookLogin::) resultBlock:nil];
}

-(void)_onFacebookLogin:(NSMutableDictionary*) data : (NSNumber*) success
{
    NSLog(@"facebook login");
    if([self _processResponse:data:success:@"load"])
    {
        
        [self mergeFromDictionary:[data objectForKey:@"user"] useKeyMapping:false];
        NSLog(@"yeah %u", self.id);
        self.loggedIn = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:self userInfo:data];
        [self commitQueuedRemoteActions];
    }
}

-(void)commitQueuedRemoteActions
{
    for (NSArray *action in self.queuedRemoteActions) {
        NSString *actionPath = [action objectAtIndex:0];
        NSDictionary *params = [action objectAtIndex:1];
        
         [_webAPI callAsPost:actionPath usingParameters:params andNotifyObject:self withSelector:@selector(_onQueuedActionComplete::) resultBlock:nil];
    }
    
    [self.queuedRemoteActions removeAllObjects];
}

-(void)_onQueuedActionComplete:(NSMutableDictionary*) data : (NSNumber*) success
{
    
}
-(void)_onRegister:(NSMutableDictionary*) data : (NSNumber*) success
{
        if([self _processResponse:data:success:@"load"])
        {
            [self mergeFromDictionary:data useKeyMapping:false];
            self.loggedIn = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:self userInfo:data];
        }
 
}

-(id) init
{
    self = [super init];
    _webAPI = [[WebAPI alloc] initWithGateway:userManagerGateway andPersistentParams:nil];
    self.loggedIn = false;
    return self;
}

-(void)logout
{
    [CurrentUserModel resetSharedModel];
}

-(void)setData:(NSDictionary*)data
{
     [_webAPI callAsPost:@"mcs/users/set" usingParameters:data andNotifyObject:self withSelector:@selector(_onSet::) resultBlock:nil];
}

-(void)resetPassword:(NSString*)email callback:(void(^)(bool))callback
{
    self.lastError = nil;
    NSDictionary *data = @{@"email" : email};
    [_webAPI callAsPost:@"usermanager/forgot" usingParameters:data andNotifyObject:self withSelector:@selector(_onResetPasswordSent::) resultBlock:callback];
}

-(void)_onResetPasswordSent:(NSMutableDictionary*) data : (NSNumber*) success
{
    NSLog(@"data: %@", data);
    self.lastError = (NSString*) data;
}

-(void)_onSet:(NSMutableDictionary*) data : (NSNumber*) success
{
    
}


@end

