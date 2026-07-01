//
//  WSContactsBookHeaderButton.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookHeaderButton.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录头按键 延展(内部)
@interface WSContactsBookHeaderButton ()

@property (nonatomic, strong) UILabel *markLabel;   //标示标签
@property (nonatomic, strong) UILabel *contentLabel;//内容标签

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头按键 延展(工具)
@interface WSContactsBookHeaderButton (Tool)

#pragma mark - 布局头按键方法
- (void)layoutHeaderButton;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头按键
@implementation WSContactsBookHeaderButton

#pragma mark - 获取markLabel方法
- (UILabel *)markLabel
{
    if(_markLabel == nil)
    {
        _markLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _markLabel.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookThemeColor];
        _markLabel.textAlignment = NSTextAlignmentCenter;
        _markLabel.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_big];
        _markLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleWhiteColor];
        _markLabel.layer.masksToBounds = YES;
        _markLabel.clipsToBounds = YES;
        _markLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _markLabel;
}

#pragma mark - 获取contentLabel方法
- (UILabel *)contentLabel
{
    if(_contentLabel == nil)
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

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.markLabel];
        [self addSubview:self.contentLabel];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutHeaderButton];
}

#pragma mark - 更新方法 mark:标示 content:内容
- (void)updateWithMark:(NSString *)mark content:(NSString *)content
{
    self.markLabel.text = mark;
    self.contentLabel.text = content;
    [self setNeedsLayout];
}

#pragma mark - 获取高度方法 mark:标示 content:内容 maxWidth:最大宽度
- (CGFloat)getHeightWithMark:(NSString *)mark content:(NSString *)content maxWidth:(CGFloat)maxWidth
{
    return kContactsBookElementHeight_standard;
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头按键 延展(工具)
@implementation WSContactsBookHeaderButton (Tool)

#pragma mark - 布局头按键方法
- (void)layoutHeaderButton
{
    CGFloat x = kContactsBookSpace_big;
    CGFloat y = (CGRectGetHeight(self.frame) - kContactsBookIconSize_standard) / 2;
    CGFloat w = kContactsBookIconSize_standard;
    CGFloat h = kContactsBookIconSize_standard;
    self.markLabel.frame = CGRectMake(x, y, w, h);
    self.markLabel.layer.cornerRadius = kContactsBookIconSize_standard / 2;
    
    x = CGRectGetMaxX(self.markLabel.frame) + kContactsBookSpace_big;
    y = 0.0f;
    w = CGRectGetWidth(self.frame) - x - kContactsBookSpace_big;
    h = CGRectGetHeight(self.frame);
    self.contentLabel.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
