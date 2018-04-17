//
//  TermsViewController.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 12/19/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "TermsViewController.h"

@implementation TermsViewController



-(void)viewWillAppear:(BOOL)animated
{
    NSString *htmlFile;
    if(self.type == 1)
    {
        NSURL *targetURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terms" ofType:@"pdf"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [self.webView loadRequest:request];
        
    }
    else
    {
        NSURL *targetURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"pdf"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [self.webView loadRequest:request];
    }
    
    
    
}
-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
