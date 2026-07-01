//
//  WSGapViewPanel.m
//  WinSFA
//
//  Created by Alicia on 16/11/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGapViewPanel.h"
#import "I_W_BuildInfo.h"
#import "GlobalUtil.h"

#define Dashed_Solidline_Height 1.0

@interface WSGapViewPanel()

@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WSGapViewPanel

- (void)buildDisplayContent
{
    [super buildDisplayContent];

    NSString *bgColorString = [xbuildInfo getBgColor];
    UIColor *bgColor;
    if (bgColorString) {
       bgColor = [UIColor colorWithHexString:bgColorString];
    } else {
        bgColor = GROUP_TABLE_BG_COLOR;
    }

    //  MN-102  添加实线虚线显示 dashed 虚线   solidline实线 add by 支庆
    CGFloat imageHeight = Dashed_Solidline_Height / [[UIScreen mainScreen] scale];

    if ([[xbuildInfo getDisplayMode] isEqualToString:@"dashed"]) {
        self.imageView.frame = CGRectMake(0, 0, self.width, imageHeight);
        UIImage * lineImage = [UIImage imageWithImage:[GlobalUtil drawLineByImageView:self.imageView] andTintColor:bgColor];
        [self.imageView setImage:lineImage];
        [self addSubview:self.imageView];
        self.bottomLineView.hidden = YES;
    } else if ([[xbuildInfo getDisplayMode] isEqualToString:@"solidline"]) {
         self.imageView.frame = CGRectMake(0, 0, self.width, imageHeight);
        self.imageView.backgroundColor = bgColor;
        [self addSubview:self.imageView];
        self.bottomLineView.hidden = YES;
    }
    
    if ([xbuildInfo getReadOnly]) {
        if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_BQ]) {
            [self setBackgroundColor:bgColor];
        }
        else{
            [self setBackgroundColor:MAIN_CELL_DISABLE_COLOR];
        }
    } else {
        if (!self.hasImage) {
            [self setBackgroundColor:bgColor];
        }
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, GROUP_CELL_PADDING)];
   
//        UIView *seperateLineViewUp  = [[UIView alloc] initWithFrame:CGRectMake(0, -MAIN_CELL_SEPERATOR_HEIGHT, self.frame.size.width, MAIN_CELL_SEPERATOR_HEIGHT)];
//        seperateLineViewUp.backgroundColor = MAIN_SEPERATE_LINE_COLOR;
//        [self addSubview:seperateLineViewUp];
//        
//        UIView *seperateLineViewDown  = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - MAIN_CELL_SEPERATOR_HEIGHT, self.frame.size.width, MAIN_CELL_SEPERATOR_HEIGHT)];
//        seperateLineViewDown.backgroundColor = MAIN_SEPERATE_LINE_COLOR;
//        [self addSubview:seperateLineViewDown];
//    
}

- (void)layoutSubviews{
    if ([xbuildInfo getQuestIconURL].length > 0) {
        CGFloat originX = CGRectGetMaxX(self.iconImageView.frame) + MAIN_TEXT_IMG_PADDING;
        self.imageView.frame = CGRectMake(originX, (self.bounds.size.height - self.imageView.height) / 2, self.bounds.size.width - originX - MAIN_TEXT_IMG_PADDING, self.imageView.height);
    }
}

#pragma mark -
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        self.hasImage = YES;
    }
    return _imageView;
}

@end
