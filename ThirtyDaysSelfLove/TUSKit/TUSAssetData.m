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

#import "TusKit.h"
#import "TUSAssetData.h"

@interface TUSAssetData ()
@property (strong, nonatomic) ALAsset* asset;
@end

@implementation TUSAssetData

- (id)initWithAsset:(ALAsset*)asset
{
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

#pragma mark - TUSData Methods
- (long long)length
{
    ALAssetRepresentation* assetRepresentation = [_asset defaultRepresentation];
    if (!assetRepresentation) {
        // NOTE:
        // defaultRepresentation "returns nil for assets from a shared photo
        // stream that are not yet available locally." (ALAsset Class Reference)

        // TODO:
        // Handle deferred availability of ALAssetRepresentation,
        // by registering for an ALAssetsLibraryChangedNotification.
        TUSLog(@"@TODO: Implement support for ALAssetsLibraryChangedNotification to support shared photo stream assets");
        return 0;
    }

    return [assetRepresentation size];
}

- (NSUInteger)getBytes:(uint8_t *)buffer
            fromOffset:(long long)offset
                length:(NSUInteger)length
                 error:(NSError **)error
{
    ALAssetRepresentation* assetRepresentation = [_asset defaultRepresentation];
    return [assetRepresentation getBytes:buffer
                              fromOffset:offset
                                  length:length
                                   error:error];
}

@end
