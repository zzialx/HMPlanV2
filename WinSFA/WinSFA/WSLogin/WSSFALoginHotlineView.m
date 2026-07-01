//
//  WSSFALoginHotlineView.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginHotlineView.h"
#import "WSEnvrionment.h"
#import "WSSFALoginGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图热线视图 延展(工具)
@interface WSSFALoginHotlineView ()

@property (nonatomic, strong) UIColor *hotlineTextColor;    //热线文本颜色

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图热线视图 延展(工具)
@interface WSSFALoginHotlineView (Tool)

- (void)layoutLoginHotline; //布局登陆热线方法

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图热线视图
@implementation WSSFALoginHotlineView

#pragma mark - 获取hotlineLabel方法
- (UILabel *)hotlineLabel
{
    if (_hotlineLabel == nil)
    {
        _hotlineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _hotlineLabel.backgroundColor = [UIColor clearColor];
        _hotlineLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
        _hotlineLabel.textColor = _hotlineTextColor;
        _hotlineLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"service_hotline", nil)];
        _hotlineLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _hotlineLabel;
}

#pragma mark - 获取hotlineTelephoneButton方法
- (UIButton *)hotlineTelephoneButton
{
    if (_hotlineTelephoneButton == nil)
    {
        _hotlineTelephoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hotlineTelephoneButton.backgroundColor = [UIColor clearColor];
        _hotlineTelephoneButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
        _hotlineTelephoneButton.contentHorizontalAlignment = NSTextAlignmentRight;
        NSString *hotlineStr = [WSEnvrionment getHotline];
        NSMutableAttributedString *contont = [[NSMutableAttributedString alloc] initWithString:hotlineStr];
        NSRange contentRange = {0, hotlineStr.length};
        [contont addAttribute:NSForegroundColorAttributeName value:_hotlineTextColor range:contentRange];
        [contont addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        [_hotlineTelephoneButton setAttributedTitle:contont forState:UIControlStateNormal];
    }
    
    return _hotlineTelephoneButton;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _hotlineSpace = kLoginViewStandardElementSpace;
        
        UIColor *color = [UIColor colorForKey:WSLoginViewHotlineTextColorMark];
        _hotlineTextColor = (color ? color : MAIN_TINT_COLOR);
        
        [self addSubview:self.hotlineLabel];
        [self addSubview:self.hotlineTelephoneButton];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutLoginHotline];
}

#pragma mark - 更新登陆热线方法
- (void)updateLoginHotline
{
    [self setNeedsLayout];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图热线视图 延展(工具)
@implementation WSSFALoginHotlineView (Tool)

#pragma mark - 布局登陆热线方法
- (void)layoutLoginHotline
{
    CGFloat drawmaxWidth = CGRectGetWidth(self.frame);
    CGFloat drawMaxHeight = CGRectGetHeight(self.frame);
    
    CGSize titleSize = [self.hotlineLabel.text ws_sizeWithFont:self.hotlineLabel.font constrainedToWidth:drawmaxWidth];
    CGSize phoneSize = [self.hotlineTelephoneButton.currentAttributedTitle.string ws_sizeWithFont:self.hotlineTelephoneButton.titleLabel.font constrainedToWidth:drawmaxWidth];
    CGFloat maxWidth = titleSize.width + self.hotlineSpace + phoneSize.width;
    CGFloat maxHeight = (titleSize.height > phoneSize.height) ? titleSize.height : phoneSize.height;
    
    CGFloat x = (drawmaxWidth - maxWidth) / 2;
    CGFloat y = (drawMaxHeight - maxHeight) / 2;
    CGFloat w = titleSize.width;
    CGFloat h = titleSize.height;
    self.hotlineLabel.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.hotlineLabel.frame) + self.hotlineSpace;
    y = (drawMaxHeight - maxHeight) / 2;
    w = phoneSize.width;
    h = phoneSize.height;
    self.hotlineTelephoneButton.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
