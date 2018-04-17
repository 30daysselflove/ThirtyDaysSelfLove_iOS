//
//  SupportCommentCell.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/6/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface SupportCommentCell : SWTableViewCell

-(void)setComment:(NSString*)comment withName:(NSString*)name;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
