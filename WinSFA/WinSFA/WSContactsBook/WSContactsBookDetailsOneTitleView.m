//
//  WSContactsBookDetailsOneTitleView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDetailsOneTitleView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情一个标题视图 延展(内部)
@interface WSContactsBookDetailsOneTitleView ()

@property (nonatomic, assign) BOOL isBottomSpace;   //是否底部空间
@property (nonatomic, strong) UILabel *titleLabel;  //标题标签

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情一个标题视图 延展(工具)
@interface WSContactsBookDetailsOneTitleView (Tools)

#pragma mark - 布局一个标题视图方法
- (void)layoutOneTitleView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情一个标题视图
@implementation WSContactsBookDetailsOneTitleView

#pragma mark - 获取titleLabel方法
- (UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_standard];
        _titleLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookGroupingTitleColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _titleLabel;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.titleLabel];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutOneTitleView];
}

#pragma mark - 更新视图方法 title:标题 isBottomSpace:是否底部空间
- (void)updateViewWithTitle:(NSString *)title isBottomSpace:(BOOL)isBottomSpace
{
    self.titleLabel.text = title;
    self.isBottomSpace = isBottomSpace;
    [self setNeedsLayout];
}

#pragma mark - 获取高度方法 title:标题 maxWidth:最大宽度 isBottomSpace:是否底部空间
- (CGFloat)getHeightWithTitle:(NSString *)title isBottomSpace:(BOOL)isBottomSpace maxWidth:(CGFloat)maxWidth
{
    if(title.length <= 0.0f || maxWidth <= 0.0f)
        return 0.0f;
    
    CGSize textSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:2000.0f];
    return (isBottomSpace ? (textSize.height + (kContactsBookSpace_standard * 2)) : (textSize.height + kContactsBookSpace_standard));
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情一个标题视图 延展(工具)
@implementation WSContactsBookDetailsOneTitleView (Tools)

#pragma mark - 布局一个标题视图方法
- (void)layoutOneTitleView
{
    CGSize textSize = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToWidth:2000.0f];
    CGFloat x = kContactsBookSpace_big;
    CGFloat y = (CGRectGetHeight(self.frame) - textSize.height) / 2;
    if(!self.isBottomSpace)
        y = kContactsBookSpace_standard;
    CGFloat w = CGRectGetWidth(self.frame) - (kContactsBookSpace_big * 2);
    CGFloat h = textSize.height;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
