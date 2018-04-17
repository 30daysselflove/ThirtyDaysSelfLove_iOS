//
//  RecordSectionNavigationController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 2/10/15.
//  Copyright (c) 2015 Adam Dougherty. All rights reserved.
//

#import "RecordSectionNavigationController.h"

@implementation RecordSectionNavigationController



- (BOOL)shouldAutorotate {
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations
{
    if(self.recording) return UIInterfaceOrientationMaskAll;
    else return UIInterfaceOrientationMaskPortrait;
}


@end
