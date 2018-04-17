//
//  BubblingActionCell.h
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/7/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BubblingActionCellDelegate <NSObject>

@required
-(void)tableViewCell:(UITableViewCell *)cell didFireActionForSender:(id)sender;

@end

@interface BubblingActionCell : UITableViewCell
-(void)fireAction:(id)sender;
@property (nonatomic, weak) id<BubblingActionCellDelegate> delegate;

@end
