//
//  BubblingActionCell.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/7/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "BubblingActionCell.h"

@implementation BubblingActionCell

-(void)fireAction:(id)sender
{
    if(self.delegate) [self.delegate tableViewCell:self didFireActionForSender:sender];
}
@end
