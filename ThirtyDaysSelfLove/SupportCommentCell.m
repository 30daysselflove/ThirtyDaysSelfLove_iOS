//
//  SupportCommentCell.m
//  ThirtyDaysSelfLove
//
//  Created by Adam Dougherty on 10/6/14.
//  Copyright (c) 2014 Adam Dougherty. All rights reserved.
//

#import "SupportCommentCell.h"

@implementation SupportCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setComment:(NSString*)comment withName:(NSString*)name
{
    const CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor blackColor];
    
    // Create the attributes
    NSDictionary *attrs = @{ NSFontAttributeName : boldFont,
                             NSForegroundColorAttributeName : foregroundColor};
    
    NSDictionary *subAttrs = @{
                               NSFontAttributeName : regularFont
                               };
    
    const NSRange range = NSMakeRange(0,name.length); // range of " 2012/10/14 ". Ideally this should not be hardcoded
    
    NSString * builtString = [NSString stringWithFormat:@"%@ %@", name, comment];
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:builtString attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    
    // Set it in our UILabel and we are done!
    [self.commentLabel setAttributedText:attributedText];
}

@end
