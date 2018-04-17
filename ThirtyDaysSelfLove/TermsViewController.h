//
//  TermsViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/19/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsViewController : UIViewController

-(IBAction)close:(id)sender;
@property (assign) NSInteger type;
@property (weak, nonatomic) IBOutlet UIWebView* webView;

@end
