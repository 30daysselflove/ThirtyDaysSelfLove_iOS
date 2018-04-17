//
//  PropagatingViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/13/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "PropagatingViewController.h"

@implementation PropagatingViewController

-(id)initWithNavControllerWithSubViewController:(UIViewController *)subviewcontroller {
    if (self = [super init]) {
        self->navController = [[UINavigationController alloc] initWithRootViewController:subviewcontroller];
        self->navController.navigationBar.barTintColor = [UIColor blackColor];
        self->navController.navigationBar.tintColor = [UIColor whiteColor];
        [self->navController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    return self;
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (self->navController != nil) {
        [self.view addSubview:self->navController.view];
        //self.view = self->navController.view; either line doesn't work.
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [self->navController viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated {
    [self->navController viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self->navController viewWillDisappear:animated];
}
-(void)viewDidDisappear:(BOOL)animated {
    [self->navController viewDidDisappear:animated];
}

@end
