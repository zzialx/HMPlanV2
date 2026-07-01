//
//  WSContactsBookDetailsPhoneView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDetailsPhoneView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情电话视图 延展(内部)
@interface WSContactsBookDetailsPhoneView ()

@property (nonatomic, assign) BOOL isShowLine;          //是否显示线
@property (nonatomic, strong) UILabel *titleLabel;      //标题标签
@property (nonatomic, strong) UILabel *contentLabel;    //内容标签
@property (nonatomic, strong) UIButton *messageButton;  //消息按键
@property (nonatomic, strong) UIButton *phoneButton;    //电话按键
@property (nonatomic, strong) UIView *lineView;         //线视图

#pragma mark - 消息按键点击响应方法 sender:按键对象
- (void)touchUpMessageButtonEnevt:(id)sender;

#pragma mark - 电话按键点击响应方法 sender:按键对象
- (void)touchUpPhoneButtonEnevt:(id)sender;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情电话视图 延展(工具)
@interface WSContactsBookDetailsPhoneView (Tools)

#pragma mark - 布局电话视图方法
- (void)layoutPhoneView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情电话视图
@implementation WSContactsBookDetailsPhoneView

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
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _contentLabel;
}

#pragma mark - 获取messageButton方法
- (UIButton *)messageButton
{
    if (_messageButton == nil)
    {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageButton.backgroundColor = [UIColor clearColor];
        [_messageButton addTarget:self action:@selector(touchUpMessageButtonEnevt:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _messageButton;
}

#pragma mark - 获取phoneButton方法
- (UIButton *)phoneButton
{
    if (_phoneButton == nil)
    {
        _phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneButton.backgroundColor = [UIColor clearColor];
        [_phoneButton addTarget:self action:@selector(touchUpPhoneButtonEnevt:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _phoneButton;
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
        [self addSubview:self.messageButton];
        [self addSubview:self.phoneButton];
        [self addSubview:self.lineView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutPhoneView];
}

#pragma mark - 更新视图方法 title:标题 content:内容 messageIcon:信息图标 phoneIcon:电话图标 isShowLine:是否显示线标示
- (void)updateViewWithTitle:(NSString *)title content:(NSString *)content messageIcon:(UIImage *)messageIcon phoneIcon:(UIImage *)phoneIcon isShowLine:(BOOL)isShowLine
{
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    [self.messageButton setImage:messageIcon forState:UIControlStateNormal];
    [self.messageButton setImage:messageIcon forState:UIControlStateSelected];
    [self.phoneButton setImage:phoneIcon forState:UIControlStateNormal];
    [self.phoneButton setImage:phoneIcon forState:UIControlStateSelected];
    self.isShowLine = isShowLine;
    
    [self setNeedsLayout];
}

#pragma mark - 获取高度方法 title:标题 content:内容 messageIcon:信息图标 phoneIcon:电话图标 isShowLine:是否显示线标示 maxWidth:最大宽度
- (CGFloat)getHeightWithTitle:(NSString *)title content:(NSString *)content messageIcon:(UIImage *)messageIcon phoneIcon:(UIImage *)phoneIcon
                   isShowLine:(BOOL)isShowLine maxWidth:(CGFloat)maxWidth
{
    if((title.length <= 0.0f && content.length <= 0.0f && !messageIcon && !phoneIcon) || maxWidth <= 0.0f)
        return 0.0f;

    CGSize titleSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:2000.0f];
    CGSize contentSize = [self.contentLabel.text ws_sizeWithFont:self.contentLabel.font constrainedToWidth:2000.0f];

    CGFloat maxHeight = (titleSize.height >= contentSize.height) ? titleSize.height : contentSize.height;
    maxHeight = (maxHeight >= kContactsBookDetailsPhoneSize) ? maxHeight : kContactsBookDetailsPhoneSize;
    if(isShowLine)
        maxHeight += (kContactsBookSpace_standard * 2) + kContactsBookLineHeight_standard;
    else
        maxHeight += (kContactsBookSpace_standard * 2);
    return maxHeight;
}

#pragma mark - 消息按键点击响应方法 sender:按键对象
- (void)touchUpMessageButtonEnevt:(id)sender
{
    if (self.messageClickBlock)
        self.messageClickBlock(self.contentLabel.text);
}

#pragma mark - 电话按键点击响应方法 sender:按键对象
- (void)touchUpPhoneButtonEnevt:(id)sender
{
    if (self.phoneClickBlock)
        self.phoneClickBlock(self.contentLabel.text);
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情电话视图 延展(工具)
@implementation WSContactsBookDetailsPhoneView (Tools)

#pragma mark - 布局电话视图方法
- (void)layoutPhoneView
{
    CGSize titleSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:2000.0f];
    CGSize contentSize = [self.contentLabel.text ws_sizeWithFont:self.contentLabel.font constrainedToWidth:2000.0f];
    CGFloat buttonWidth = (kContactsBookDetailsPhoneSize * 2) + kContactsBookSpace_standard;
    
    CGFloat maxHeight = (titleSize.height >= contentSize.height) ? titleSize.height : contentSize.height;
    maxHeight = (maxHeight >= kContactsBookDetailsPhoneSize) ? maxHeight : kContactsBookDetailsPhoneSize;
    maxHeight += (kContactsBookSpace_standard * 2);
    
    CGFloat x = kContactsBookSpace_big;
    CGFloat y = (maxHeight - titleSize.height) / 2;
    CGFloat w = kContactsBookDetailsLeftTitleMaxWidth - (kContactsBookSpace_big * 2);
    CGFloat h = titleSize.height;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
    
    x = kContactsBookDetailsLeftTitleMaxWidth;
    y = (maxHeight - contentSize.height) / 2;
    w = CGRectGetWidth(self.frame) - x - buttonWidth - (kContactsBookSpace_big * 2);
    h = contentSize.height;
    self.contentLabel.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetWidth(self.frame) - kContactsBookSpace_big - buttonWidth;
    y = (maxHeight - kContactsBookDetailsPhoneSize) / 2;
    w = kContactsBookDetailsPhoneSize;
    h = kContactsBookDetailsPhoneSize;
    self.messageButton.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.messageButton.frame) + kContactsBookSpace_standard;
    y = (maxHeight - kContactsBookDetailsPhoneSize) / 2;
    w = kContactsBookDetailsPhoneSize;
    h = kContactsBookDetailsPhoneSize;
    self.phoneButton.frame = CGRectMake(x, y, w, h);
    
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
