//
//  WSHighFrequencySearchResultCell.m
//  WinSFA
//
//  Created by yuanji on 2018/11/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSHighFrequencySearchResultCell.h"
//=====================================================================================================================================

#pragma mark - 高频搜索结果单元格 延展(内部)
@interface WSHighFrequencySearchResultCell ()

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果单元格 延展(工具)
@interface WSHighFrequencySearchResultCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell;

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果单元格
@implementation WSHighFrequencySearchResultCell

#pragma mark - 设置单元格数据方法 text:文本
- (void)setCellWithText:(NSString *)text {
    self.titleLabel.text = (text.length > 0 ? text : @"");
    [self setNeedsLayout];
}

#pragma mark - 获取titleLabel方法
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont fontForKey:@"HighFrequencySearchTitle"];
        _titleLabel.textColor = [UIColor colorForKey:@"HighFrequencySearchTitle"];
    }
    return _titleLabel;
}

#pragma mark - 获取deleteButton方法
- (UIButton *)deleteButton {
    if(!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor clearColor];
        [_deleteButton setImage:[UIImage scaledImageForName:@"deleteIcon" ofType:@"png"] forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage scaledImageForName:@"deleteIcon" ofType:@"png"] forState:UIControlStateSelected];
    }
    return _deleteButton;
}

#pragma mark - 获取lineView方法
- (UIView *)lineView {
    if(!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorForKey:@"HighFrequencySearchLineColor"];
    }
    return _lineView;
}

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutCell];
}

@end
//=====================================================================================================================================

#pragma mark - 高频搜索结果单元格 延展(工具)
@implementation WSHighFrequencySearchResultCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell {

    CGFloat lineHeight = 0.5f;
    CGFloat maxDrawWidth = CGRectGetWidth(self.contentView.frame) - (MAIN_PADDING * 2);
    CGFloat maxDrawHeight = CGRectGetHeight(self.contentView.frame) - lineHeight;
    UIImage *image = [UIImage scaledImageForName:@"deleteIcon" ofType:@"png"];
    
    CGFloat x = MAIN_PADDING;
    CGFloat y = 0.0f;
    CGFloat w = maxDrawWidth - image.size.width - MAIN_PADDING;
    CGFloat h = maxDrawHeight;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.titleLabel.frame) + MAIN_PADDING;
    y = (maxDrawHeight - image.size.height) / 2;
    w = image.size.width;
    h = image.size.height;
    self.deleteButton.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = maxDrawHeight;
    w = CGRectGetWidth(self.contentView.frame);
    h = lineHeight;
    self.lineView.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================

