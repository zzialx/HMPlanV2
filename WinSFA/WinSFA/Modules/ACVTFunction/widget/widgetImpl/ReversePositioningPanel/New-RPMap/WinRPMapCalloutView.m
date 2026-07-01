//
//  WinRPMapCalloutView.m
//  WinSFA
//
//  Created by yuanji on 2019/9/30.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapCalloutView.h"
//=================================================================================================================================

#pragma mark - RP地图用户标注视图 延展(内部)
@interface WinRPMapCalloutView ()

@end
//=================================================================================================================================

#pragma mark - RP地图用户标注视图 延展(工具)
@interface WinRPMapCalloutView (Tools)

- (void)layoutCalloutView; //布局标注视图方法

@end
//=================================================================================================================================

#pragma mark - RP地图用户标注视图
@implementation WinRPMapCalloutView

#pragma mark - 获取titleLabel方法
- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

#pragma mark - 获取subtitleLabel方法
- (UILabel *)subtitleLabel {
    
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _subtitleLabel.textColor = [UIColor blackColor];
        _subtitleLabel.numberOfLines = 0;
    }
    return _subtitleLabel;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutCalloutView];
}

#pragma mark - 获取标注视图尺寸方法
+ (CGSize)getCalloutViewSizeWithTitle:(NSString *)title subtitle:(NSString *)subtitle maxWidth:(CGFloat)maxWidth {
    
    CGFloat leftSpace = 10.0f;
    CGFloat upSpace = 5.0f;
    CGFloat textMaxWidth = maxWidth - (leftSpace * 2);
    CGSize titleSize = [title ws_sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToWidth:textMaxWidth];
    CGSize subtitleSize = [subtitle ws_sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToWidth:textMaxWidth];
    
    CGFloat width = ((titleSize.width >= subtitleSize.width) ? titleSize.width : subtitleSize.width) + (leftSpace * 2);
    width = (width <= maxWidth) ? width : maxWidth;
    CGFloat height = (upSpace + titleSize.height + upSpace + subtitleSize.height + upSpace);
    return CGSizeMake(width, height);
}

#pragma mark - 设置标注视图方法
- (void)setCalloutViewWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    
    self.titleLabel.text = (title.length > 0) ? title : @"";
    self.subtitleLabel.text = (subtitle.length > 0) ? subtitle : @"";
    [self setNeedsLayout];
}

@end
//=================================================================================================================================

#pragma mark - RP地图用户标注视图 延展(工具)
@implementation WinRPMapCalloutView (Tools)

#pragma mark - 布局标注视图方法
- (void)layoutCalloutView {
    
    CGFloat leftSpace = 10.0f;
    CGFloat upSpace = 5.0f;
    CGFloat textMaxWidth = CGRectGetWidth(self.frame) - (leftSpace * 2);
    CGSize titleSize = [self.titleLabel.text ws_sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToWidth:textMaxWidth];
    CGSize subtitleSize = [self.subtitleLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToWidth:textMaxWidth];
    
    CGFloat x = leftSpace;
    CGFloat y = upSpace;
    CGFloat w = titleSize.width;
    CGFloat h = titleSize.height;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
    
    x = leftSpace;
    y = CGRectGetMaxY(self.titleLabel.frame) + upSpace;
    w = subtitleSize.width;
    h = subtitleSize.height;
    self.subtitleLabel.frame = CGRectMake(x, y, w, h);
}

@end
//=================================================================================================================================

