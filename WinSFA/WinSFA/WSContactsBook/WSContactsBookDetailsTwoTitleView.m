//
//  WSContactsBookDetailsTwoTitleView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDetailsTwoTitleView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情二个标题视图 延展(内部)
@interface WSContactsBookDetailsTwoTitleView ()

@property (nonatomic, assign) BOOL isShowLine;          //是否显示线
@property (nonatomic, strong) UILabel *titleLabel;      //标题标签
@property (nonatomic, strong) UILabel *contentLabel;    //内容标签
@property (nonatomic, strong) UIView *lineView;         //线视图

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情二个标题视图 延展(工具)
@interface WSContactsBookDetailsTwoTitleView (Tools)

#pragma mark - 布局二个标题视图方法
- (void)layoutTwoTitleView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情二个标题视图
@implementation WSContactsBookDetailsTwoTitleView

#pragma mark - 获取titleLabel方法
- (UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_standard];
        _titleLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleGrayColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _titleLabel;
}

#pragma mark - 获取contentLabel方法
- (UILabel *)contentLabel
{
    if (_contentLabel == nil)
    {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_standard];
        _contentLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleBlackColor];
        _contentLabel.numberOfLines = 0;
    }
    
    return _contentLabel;
}

#pragma mark - 获取lineView方法
- (UIView *)lineView
{
    if(_lineView == nil)
    {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookLineColor];
    }
    
    return _lineView;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.lineView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutTwoTitleView];
}

#pragma mark - 更新视图方法 title:标题 content:内容 isShowLine:是否显示线标示
- (void)updateViewWithTitle:(NSString *)title content:(NSString *)content isShowLine:(BOOL)isShowLine
{
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    self.isShowLine = isShowLine;
    
    [self setNeedsLayout];
}

#pragma mark - 获取高度方法 title:标题 content:内容 isShowLine:是否显示线标示 maxWidth:最大宽度
- (CGFloat)getHeightWithTitle:(NSString *)title content:(NSString *)content isShowLine:(BOOL)isShowLine maxWidth:(CGFloat)maxWidth
{
    if((title.length <= 0.0f && content.length <= 0.0f) || maxWidth <= 0.0f)
        return 0.0f;
    
    CGSize titleSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:2000.0f];
    CGFloat maxDrawWidth = maxWidth - kContactsBookDetailsLeftTitleMaxWidth - kContactsBookSpace_big;
    CGSize contentSize = [self.contentLabel.text ws_sizeWithFont:self.contentLabel.font constrainedToWidth:maxDrawWidth];
    
    CGFloat maxHeight = (titleSize.height >= contentSize.height) ? titleSize.height : contentSize.height;
    if(isShowLine)
        maxHeight += (kContactsBookSpace_standard * 2) + kContactsBookLineHeight_standard;
    else
        maxHeight += (kContactsBookSpace_standard * 2);
    return maxHeight;
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情二个标题视图 延展(工具)
@implementation WSContactsBookDetailsTwoTitleView (Tools)

#pragma mark - 布局二个标题视图方法
- (void)layoutTwoTitleView
{
    CGSize titleSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:2000.0f];
    CGFloat maxDrawWidth = CGRectGetWidth(self.frame) - kContactsBookDetailsLeftTitleMaxWidth - kContactsBookSpace_big;
    CGSize contentSize = [self.contentLabel.text ws_sizeWithFont:self.contentLabel.font constrainedToWidth:maxDrawWidth];
    CGFloat maxHeight = (titleSize.height >= contentSize.height) ? titleSize.height : contentSize.height;
    maxHeight += (kContactsBookSpace_standard * 2);
    
    CGFloat x = kContactsBookSpace_big;
    CGFloat y = (maxHeight - titleSize.height) / 2;
    CGFloat w = kContactsBookDetailsLeftTitleMaxWidth - (kContactsBookSpace_big * 2);
    CGFloat h = titleSize.height;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
    
    x = kContactsBookDetailsLeftTitleMaxWidth;
    y = (maxHeight - contentSize.height) / 2;
    w = contentSize.width;
    h = contentSize.height;
    self.contentLabel.frame = CGRectMake(x, y, w, h);
    
    if(self.isShowLine)
    {
        x = kContactsBookSpace_big;
        y = maxHeight;
        w = CGRectGetWidth(self.frame) - x;
        h = kContactsBookLineHeight_standard;
        self.lineView.frame = CGRectMake(x, y, w, h);
    }
    else
        self.lineView.frame = CGRectZero;
}

@end
//===================================================================================================================================================================
