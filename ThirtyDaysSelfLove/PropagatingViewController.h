//
//  PropagatingViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/13/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PropagatingViewController : UIViewController
{
    UINavigationController *navController;
}

-(id)initWithNavControllerWithSubViewController:(UIViewController *)subviewcontroller;
@end
