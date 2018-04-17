//
//  CustomTabController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 11/24/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabController : UITabBarController <UITabBarControllerDelegate>
{
    @private
    UIViewController *_dummyController;
}
@end
