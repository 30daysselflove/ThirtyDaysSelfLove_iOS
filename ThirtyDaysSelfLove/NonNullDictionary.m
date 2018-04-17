//
//  NonNullDictionary.m
//  Blizzfull for iPad
//
//  Created by Tim Bitch on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NonNullDictionary.h"

@implementation NSMutableDictionary (NonNullDictionary)
- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;
    
    return object;
}
@end
