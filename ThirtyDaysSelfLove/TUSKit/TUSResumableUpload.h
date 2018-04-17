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

#import <Foundation/Foundation.h>

typedef void (^TUSUploadResultBlock)(NSURL* fileURL);
typedef void (^TUSUploadFailureBlock)(NSError* error);
typedef void (^TUSUploadProgressBlock)(NSInteger bytesWritten, NSInteger bytesTotal);

NS_ENUM(long long, TUSRangeBytes) {TUSInvalidRange = -1};

@class TUSData;

@interface TUSResumableUpload : NSObject <NSURLConnectionDelegate>


@property (readwrite, copy) TUSUploadResultBlock resultBlock;
@property (readwrite, copy) TUSUploadFailureBlock failureBlock;
@property (readwrite, copy) TUSUploadProgressBlock progressBlock;

@property (strong, nonatomic) NSDictionary *customHeaders;

- (id)initWithURL:(NSString *)url
              data:(TUSData *)data
       fingerprint:(NSString *)fingerprint;
- (void) start;

@end
