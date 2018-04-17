//
//  WebAPI.m
//  Blizzfull for iPhone
//
//  Created by Adam Dougherty on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebAPI.h"
#import "JSONKit.h"
#import "NonNullDictionary.h"
#import "FileParameter.h"
#import "AFNetworking.h"

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '@' ||
                   thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@implementation WebAPI 


@synthesize gateway;

- (NSString*) convertToURLString:(NSDictionary*) dictionary
{
    NSMutableArray *parts = [NSMutableArray new];
    for (id key in dictionary) {
        id value = [dictionary objectForKey:key];
        [parts addObject:[NSString stringWithFormat:@"%@=%@", urlEncode(key), urlEncode(value)]];
    }
    return [parts componentsJoinedByString:@"&"];
}

- (NSURLRequest *) _constructURLRequestWithPath: (NSString * ) path andParameters: (NSDictionary *) params usingMethod:(httpMethods) method
{
    NSString * fullURL;
    NSMutableURLRequest *request;
    
    NSString * apiGateway = _alternateGateway ? _alternateGateway : _gateway;
    if(method == GET)
    {
        if(_persistentParamters.count == 0)
        {
            fullURL = [NSString stringWithFormat:@"%@/%@?%@", apiGateway, path, [self convertToURLString:params]];
        }
        else
        {
            fullURL = [NSString stringWithFormat:@"%@/%@?%@&%@", apiGateway, path, [self convertToURLString:params], [self convertToURLString:_persistentParamters]];
        }
        
    }else
    {
        fullURL = [apiGateway stringByAppendingFormat:@"/%@", path];
    }
    
    NSString * escapedURL = [fullURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL *myURL = [NSURL URLWithString:escapedURL];
    
    
    if(method == POST) 
    {
        FileParameter *fileParam;
        NSMutableDictionary * filePostParams;
        for(id param in params)
        {
            id value = params[param];
            if([value isKindOfClass:[FileParameter class]])
            {
                filePostParams = [NSMutableDictionary dictionaryWithDictionary:params];
                [filePostParams removeObjectForKey:param];
                fileParam = value;
                break;
            }
                
        }
        
        if(fileParam)
        {
            NSError * __autoreleasing error;
            AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
            //here post url and imagedataa is data conversion of image  and fileimg is the upload image with that name in the php code
            
            request =[serializer multipartFormRequestWithMethod:@"POST" URLString:escapedURL
                                            parameters:filePostParams
                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                 [formData appendPartWithFileData:fileParam.data
                                                             name:fileParam.name
                                                         fileName:fileParam.fileName
                                                         mimeType:fileParam.mimeType];
                             } error: &error];
        }
        else
        {
            request = [NSMutableURLRequest requestWithURL:myURL
                                                                   cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                               timeoutInterval:10];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            
            NSLog(@"request :%@", request);
            
            request.HTTPMethod = @"POST";
            
            id finalParams;
            if(_persistentParamters.count == 0)
            {
                finalParams = params;
            }
            else
            {
                finalParams = [NSMutableDictionary dictionaryWithDictionary:params];
                [finalParams addEntriesFromDictionary:_persistentParamters];
            }
            
            NSString * escapedParams = [[self convertToURLString: finalParams]  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSLog(@"params: %@", params);
            NSData * reqData = [NSData dataWithBytes: [escapedParams UTF8String] length: [escapedParams length]];
            request.HTTPBody = reqData;

        }
        
    }
    else
    {
        request = [NSMutableURLRequest requestWithURL:myURL
                                                               cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                           timeoutInterval:10];
    }

    return request;
    
}


- (void) resetAlternateGateway
{
    _alternateGateway = nil;
}

- (void) useAlternateGateway:(NSString *)altGateway
{
    _alternateGateway = altGateway;
}

- (void) call: (NSString*) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector resultBlock:(void(^)(bool))resultBlock
{   
    [self call:path usingParameters:params andNotifyObject:object withSelector:selector andProvideContext:[NSNull null] resultBlock:resultBlock];
    
}

- (void) call: (NSString *) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector andProvideContext:(id) context resultBlock:(void(^)(bool))resultBlock
{
    
    NSURLRequest * req = [self _constructURLRequestWithPath:path andParameters: params usingMethod: GET];
   // [self createCallback:req :object :selector: context];
    
    NSLog(@"req :%@", req);
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error) {
            bool success;
            if(httpResponse.statusCode == 200) success = YES;
            else success = NO;
            NSError *parseError;
            id parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            if (!parseError) {
                NSDictionary *retData;
                
                if([(NSDictionary*)parsedData objectForKeyNotNull:@"response"])
                {
                    retData = parsedData[@"response"];
                }
                else if([(NSDictionary*)parsedData objectForKeyNotNull:@"data"])
                {
                    retData = parsedData[@"data"];
                }
                else
                {
                    retData = parsedData;
                }
        
                if(success)
                {
                    [object performSelector:selector withObject:retData withObject:@YES];

                }
                else
                {
                    [object performSelector:selector withObject:retData withObject:@NO];
                }
                
            } else {
                NSLog(@"parse error %@", parseError);
                success = NO;
                [object performSelector:selector withObject:@"Unexpected Response from Server" withObject:@NO];
            }
            if(resultBlock)resultBlock(success);
        } else {
            [object performSelector:selector withObject:error.localizedDescription withObject:@NO];
            if(resultBlock)resultBlock(NO);
        }
    }];
}


- (void) callAsPost: (NSString*) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector resultBlock:(void(^)(bool))resultBlock
{
    
    [self callAsPost:path usingParameters:params andNotifyObject:object withSelector:selector andProvideContext:[NSNull null] resultBlock:resultBlock];
    
}

- (void) callAsPost: (NSString*) path usingParameters:(NSDictionary *) params andNotifyObject:(id) object withSelector:(SEL) selector andProvideContext:(id) context resultBlock:(void(^)(bool))resultBlock
{   
    
    NSURLRequest * req = [self _constructURLRequestWithPath:path andParameters: params usingMethod: POST];
   // [self createCallback:req :object :selector :context];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
NSLog(@"yeah :%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        if (!error) {
            NSError *parseError;
            
            bool success;
            if(httpResponse.statusCode == 200) success = YES;
            else success = NO;
            
            id parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            
            if (!parseError) {
                NSDictionary *retData;
                
                if([(NSDictionary*)parsedData objectForKeyNotNull:@"response"])
                {
                    retData = parsedData[@"response"];
                }
                else if([(NSDictionary*)parsedData objectForKeyNotNull:@"data"])
                {
                    retData = parsedData[@"data"];
                }
                else
                {
                    retData = parsedData;
                }
            
                if(success)
                {
                    [object performSelector:selector withObject:retData withObject:@YES];
                }
                else
                {
                    [object performSelector:selector withObject:retData withObject:@NO];
                }
            } else {
                success = NO;
                [object performSelector:selector withObject:@"Unexpected Response from Server" withObject:@NO];
            }
            if(resultBlock)
            {
                resultBlock(success);
            }
        } else {
            //Connection or other other stack error
            [object performSelector:selector withObject:error.localizedDescription withObject:@NO];
            if(resultBlock)resultBlock(NO);
        }
    }];
}


-(void) addPersistentParamter:(NSDictionary *)param
{
    [_persistentParamters addEntriesFromDictionary:param];
}

- (id) initWithGateway:(NSString *) gatewayURL andPersistentParams:(NSMutableDictionary *)params
{
    self = [super init];
    _gateway = gatewayURL;
    _persistentParamters = params;
    return self;
}
@end
