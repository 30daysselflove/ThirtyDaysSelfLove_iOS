//
//  VideosListViewController.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/3/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideosCollection.h"
#import "BubblingActionCell.h"
#import "HeartProgressIndicator.h"

@class VideosCollection;

@interface VideosListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BubblingActionCellDelegate, UINavigationControllerDelegate>
{
    VideosCollection *_videos;
    UILabel *hintLabel;
}
-(IBAction)invite:(id)sender;
-(IBAction)listTypeSegementChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *videosList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *listTypeSelector;
@property (weak, nonatomic) IBOutlet HeartProgressIndicator *progressIndicator;
@property (assign) VideoListContext context;

@end
