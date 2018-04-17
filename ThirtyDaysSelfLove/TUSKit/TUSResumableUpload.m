//
// Copyright (c) 2013 Transloadit Ltd and Contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "TUSKit.h"
#import "TUSData.h"

#import "TUSResumableUpload.h"

#define HTTP_PATCH @"PATCH"
#define HTTP_POST @"POST"
#define HTTP_HEAD @"HEAD"
#define HTTP_OFFSET @"Offset"
#define HTTP_FINAL_LENGTH @"Entity-Length"
#define HTTP_LOCATION @"Location"
#define REQUEST_TIMEOUT 30

typedef NS_ENUM(NSInteger, TUSUploadState) {
    Idle,
    CheckingFile,
    CreatingFile,
    UploadingFile,
};

@interface TUSResumableUpload ()
@property (strong, nonatomic) TUSData *data;
@property (strong, nonatomic) NSURL *endpoint;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *fingerprint;
@property (nonatomic) long long offset;
@property (nonatomic) TUSUploadState state;
@property (strong, nonatomic) void (^progress)(NSInteger bytesWritten, NSInteger bytesTotal);
@end

@implementation TUSResumableUpload

- (id)initWithURL:(NSString *)url
             data:(TUSData *)data
      fingerprint:(NSString *)fingerprint
{
    self = [super init];
    if (self) {
        [self setEndpoint:[NSURL URLWithString:url]];
        [self setData:data];
        [self setFingerprint:fingerprint];
    }
    return self;
}

- (void) start
{
    if (self.progressBlock) {
        self.progressBlock(0, 0);
    }

    NSString *uploadUrl = [[self resumableUploads] valueForKey:[self fingerprint]];
    if (uploadUrl == nil) {
        TUSLog(@"No resumable upload URL for fingerprint %@", [self fingerprint]);
        [self createFile];
        return;
    }

    [self setUrl:[NSURL URLWithString:uploadUrl]];
    [self checkFile];
}

- (void) createFile
{
    [self setState:CreatingFile];

    long long size = [[self data] length];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", @(size)], HTTP_FINAL_LENGTH, nil];
    [headers addEntriesFromDictionary:self.customHeaders];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self endpoint] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    [request setHTTPMethod:HTTP_POST];
    [request setHTTPShouldHandleCookies:NO];
    
    [request setAllHTTPHeaderFields:headers];

    NSURLConnection *connection __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) checkFile
{
    [self setState:CheckingFile];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    [request setHTTPMethod:HTTP_HEAD];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLConnection *connection __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) uploadFile
{
    [self setState:UploadingFile];
    
    __weak TUSResumableUpload* upload = self;
    self.data.failureBlock = ^(NSError* error) {
        TUSLog(@"Failed to upload to %@ for fingerprint %@", [upload url], [upload fingerprint]);
        if (upload.failureBlock) {
            upload.failureBlock(error);
        }
    };
    self.data.successBlock = ^() {
        [upload setState:Idle];
        TUSLog(@"Finished upload to %@ for fingerprint %@", [upload url], [upload fingerprint]);
        NSMutableDictionary* resumableUploads = [upload resumableUploads];
        [resumableUploads removeObjectForKey:[upload fingerprint]];
        BOOL success = [resumableUploads writeToURL:[upload resumableUploadsFilePath]
                                         atomically:YES];
        if (!success) {
            TUSLog(@"Unable to save resumableUploads file");
        }
        if (upload.resultBlock) {
            upload.resultBlock(upload.url);
        }
    };
    
    long long offset = [self offset];
    TUSLog(@"Resuming upload at %@ for fingerprint %@ from offset %lld",
          [self url], [self fingerprint], offset);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    [request setHTTPMethod:HTTP_PATCH];
    [request setHTTPBodyStream:[[self data] dataStream]];
    
    long long bytes = [[self data] length];
    
    [request setHTTPShouldHandleCookies:NO];
    
    
    NSDictionary *standardHeaders = @{
        HTTP_OFFSET: [NSString stringWithFormat:@"%lld", offset],
        @"Content-Type": @"application/offset+octet-stream",
        @"Content-Length": [NSString stringWithFormat:@"%lld", bytes - offset],
    };
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers addEntriesFromDictionary:standardHeaders];
    [headers addEntriesFromDictionary:self.customHeaders];
    
    
    [request setAllHTTPHeaderFields:headers];
    
    NSURLConnection *connection __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate Protocol Delegate Methods
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    TUSLog(@"ERROR: connection did fail due to: %@", error);
    [connection cancel];
    [[self data] stop];
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

#pragma mark - NSURLConnectionDataDelegate Protocol Delegate Methods

// TODO: Add support to re-initialize dataStream
- (NSInputStream *)connection:(NSURLConnection *)connection
            needNewBodyStream:(NSURLRequest *)request
{
    TUSLog(@"ERROR: connection requested new body stream, which is currently not supported");
    return nil;
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    
    NSLog(@"STATUS CODE: %@", @([httpResponse statusCode]));
    
    switch([self state]) {
        case CheckingFile: {
            if (httpResponse.statusCode != 200) {
                NSLog(@"Server responded with %d. Restarting upload",
                      httpResponse.statusCode);
                [self createFile];
                return;
            }
            NSString *rangeHeader = [headers valueForKey:HTTP_OFFSET];
            if (rangeHeader) {
                long long size = [rangeHeader longLongValue];
                if (size >= [self offset]) {
                  //TODO: we skip file upload, but we mightly verifiy that file?
                  [self setState:Idle];
                  TUSLog(@"Skipped upload to %@ for fingerprint %@", [self url], [self fingerprint]);
                  NSMutableDictionary* resumableUploads = [self resumableUploads];
                  [resumableUploads removeObjectForKey:[self fingerprint]];
                  BOOL success = [resumableUploads writeToURL:[self resumableUploadsFilePath]
                                                   atomically:YES];
                  if (!success) {
                    TUSLog(@"Unable to save resumableUploads file");
                  }
                  if (self.resultBlock) {
                    self.resultBlock(self.url);
                  }
                  break;
                } else {
                  [self setOffset:size];
                }
                TUSLog(@"Resumable upload at %@ for %@ from %lld (%@)",
                      [self url], [self fingerprint], [self offset], rangeHeader);
            }
            else {
                TUSLog(@"Restarting upload at %@ for %@", [self url], [self fingerprint]);
            }
            [self uploadFile];
            break;
        }
        case CreatingFile: {
            if (httpResponse.statusCode != 201) {
                NSLog(@"Server responded with %d. File not created.", httpResponse.statusCode);
                return;
            }
            NSString *location = [headers valueForKey:HTTP_LOCATION];
            NSLog(@"location: %@", location);
            [self setUrl:[NSURL URLWithString:location]];
            TUSLog(@"Created resumable upload at %@ for fingerprint %@",
                  [self url], [self fingerprint]);
            NSURL* fileURL = [self resumableUploadsFilePath];
            NSMutableDictionary* resumableUploads = [self resumableUploads];
            [resumableUploads setValue:location forKey:[self fingerprint]];
            BOOL success = [resumableUploads writeToURL:fileURL atomically:YES];
            if (!success) {
                TUSLog(@"Unable to save resumableUploads file");
            }
            [self uploadFile];
            break;
        }
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    switch([self state]) {
        case UploadingFile:
            NSLog(@"yoyoyoyo");
            if (self.progressBlock) {
                self.progressBlock(totalBytesWritten+[self offset], [[self data] length]+[self offset]);
            }
            break;
        default:
            break;
    }

}


#pragma mark - Private Methods
- (NSMutableDictionary*)resumableUploads
{
    static id resumableUploads = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL* resumableUploadsPath = [self resumableUploadsFilePath];
        resumableUploads = [NSMutableDictionary dictionaryWithContentsOfURL:resumableUploadsPath];
        if (!resumableUploads) {
            resumableUploads = [[NSMutableDictionary alloc] init];
        }
    });

    return resumableUploads;
}

- (NSURL*)resumableUploadsFilePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* directories = [fileManager URLsForDirectory:NSApplicationSupportDirectory
                                               inDomains:NSUserDomainMask];
    NSURL* applicationSupportDirectoryURL = [directories lastObject];
    NSString* applicationSupportDirectoryPath = [applicationSupportDirectoryURL absoluteString];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:applicationSupportDirectoryPath
                           isDirectory:&isDirectory]) {
        NSError* error = nil;
        BOOL success = [fileManager createDirectoryAtURL:applicationSupportDirectoryURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
        if (!success) {
            TUSLog(@"Unable to create %@ directory due to: %@",
                  applicationSupportDirectoryURL,
                  error);
        }
    }
    return [applicationSupportDirectoryURL URLByAppendingPathComponent:@"TUSResumableUploads.plist"];
}

@end
