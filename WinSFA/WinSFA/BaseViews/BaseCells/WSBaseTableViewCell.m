//
//  WSBaseTableViewCell.m
//  WinSFA
//
//  Created by Stephanie on 16/8/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseTableViewCell.h"

#define CELL_LEFT_SPACE (INTERFACE_IS_PHONE ? 15.0f : 20.0f)
#define INDICATOR_ICON_WIDTH 20.0f


@implementation WSBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        if (!IOS7_OR_LATER) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        self.indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage scaledImageForName:@"arrow_right" ofType:@"png"]];
        self.indicatorImageView.frame = CGRectMake(self.contentView.width - CELL_LEFT_SPACE - INDICATOR_ICON_WIDTH, (self.height - INDICATOR_ICON_WIDTH)/2, INDICATOR_ICON_WIDTH, INDICATOR_ICON_WIDTH);
        self.indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.indicatorImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: self.indicatorImageView];
        
//        self.separatorLineColor = RGBCOLOR(218, 218, 218);//[UIColor colorWithHexString:@"#c7c7c7"];
        
    }
    
    return self;
}

- (void)setShowIndicatorImage:(BOOL)showIndicatorImage
{
    _showIndicatorImage = showIndicatorImage;
    
    self.indicatorImageView.hidden = !showIndicatorImage;
}

//- (void)setStyleWithIndexPath:(NSIndexPath *)indexPath totalCount:(NSInteger)totalCount
//{
//    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
//    if (indexPath.row == 0) {
//        if (!self.TopLineView) {
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, lineHeight)];
//            line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            line.backgroundColor = self.separatorLineColor;
//            self.TopLineView = line;
//        }
        
//        self.TopLineView.frame = CGRectMake(0, 0, self.contentView.width, lineHeight);
//        [self.contentView addSubview:self.TopLineView];
//    }else {
//        [self.TopLineView removeFromSuperview];
//    }
    
//    if (!self.separatorLineView) {
//        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
//        line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        line.backgroundColor = self.separatorLineColor;
//        [self.contentView addSubview:line];
//        self.separatorLineView = line;
//    }
    
//    CGFloat xOffset = 15;
//    if (indexPath.row == totalCount - 1) {
//        xOffset = 0;
//    }
    
//    self.separatorLineView.frame = CGRectMake(xOffset, self.contentView.height - lineHeight, self.contentView.width, lineHeight);
    
    
//    if (totalCount > 2) {
//        if (indexPath.row % 2 == 0) {
//            self.contentView.backgroundColor = [UIColor whiteColor];
//        }else {
//            self.contentView.backgroundColor = [UIColor colorWithHexString:@"#fbfaf8"];
//        }
//    }
//}


@end
