//
//  NonNullDictionary.h
//  Blizzfull for iPad
//
//  Created by Tim Bitch on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NonNullDictionary)
- (id)objectForKeyNotNull:(id)key;

@end
