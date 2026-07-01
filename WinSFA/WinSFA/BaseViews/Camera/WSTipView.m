//
//  WSTipView.m
//  WinSFA
//
//  Created by macbook  on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSTipView.h"

#define KIconSpace 4
#define kFontSizeRatio  (INTERFACE_IS_PHONE ? 0.0344 : 0.012)
#define kBgWidthRatio   (INTERFACE_IS_PHONE ? 1.0 : 0.15)

@interface WSTipView ()

@property (nonatomic, assign) UIImage *iconImage;
@property (nonatomic, assign) NSString *tip;
@end

@implementation WSTipView
-(instancetype)initWithFrame:(CGRect)frame image: (UIImage *)image tip: (NSString *)tip {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconImage = image;
        self.tip = tip;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    if (!self.tip || [self.tip length] == 0) {
        return;
    }
    
    CGFloat iconWidth = 0;
    if (self.iconImage) {
        iconWidth = self.iconImage.size.width;
    }
    
    CGFloat width = self.width * kBgWidthRatio - iconWidth - MAIN_CELL_PADDING - GROUP_CELL_PADDING;
    CGFloat textFontSize = SCREEN_WIDTH * kFontSizeRatio;
    CGSize textSize = [self.tip ws_sizeWithFont:FONT_SIZE_PINGFANG_REGULAR(textFontSize) constrainedToWidth:width];
    CGFloat padding = GROUP_CELL_PADDING + KIconSpace + self.iconImage.size.width;
    CGRect labelRect = CGRectMake(padding, MAIN_TEXT_IMG_PADDING, textSize.width, textSize.height);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    [label setTextColor:[UIColor colorForKey:@"NormalContentTextColor"]];
    [label setFont:FONT_SIZE_PINGFANG_REGULAR(kFontSizeRatio * SCREEN_WIDTH)];
    [label setText:self.tip];
    [label setNumberOfLines:-1];
    [self addSubview:label];
    
    if (self.iconImage) {
        CGRect iconFrame = CGRectMake(GROUP_CELL_PADDING, MAIN_TEXT_IMG_PADDING + (textSize.height - iconWidth) * 0.5, iconWidth, iconWidth);
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        [iconImageView setImage:self.iconImage];
        [iconImageView setContentMode:UIViewContentModeCenter];
        [self addSubview:iconImageView];
    }
}


+(CGSize)getTipViewFrame: (NSString *)qstTip iconImage: (UIImage *)iconImage {
    CGFloat height = 0;
    CGFloat width = 0;
    if (qstTip && [qstTip length] > 0) {
        CGFloat textFontSize = SCREEN_WIDTH * kFontSizeRatio;
        CGSize textSize = [qstTip ws_sizeWithFont:FONT_SIZE_PINGFANG_REGULAR(textFontSize) constrainedToWidth:SCREEN_WIDTH];
        width = textSize.width + MAIN_CELL_PADDING + KIconSpace + GROUP_CELL_PADDING;
        height = textSize.height;
        
        if (iconImage && INTERFACE_IS_PHONE) {
            CGFloat iconWidth = 0;
            iconWidth = iconImage.size.width;
            
            width += iconWidth;
            if (width > SCREEN_WIDTH) {
                width = SCREEN_WIDTH - MAIN_CELL_PADDING * 2;
            }
        }
    }
    
    
    return CGSizeMake(width, height);
}
@end
