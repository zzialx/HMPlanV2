//
//  WSContactsBookNameTableViewCell.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookNameTableViewCell.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录姓名表视图单元格 延展(内部)
@interface WSContactsBookNameTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;   //头像视图
@property (nonatomic, strong) UILabel *mainTitle;           //主标题
@property (nonatomic, strong) UILabel *auxiliaryTitle;      //副标题
@property (nonatomic, strong) UIView *lineView;             //线视图

@end
//===================================================================================================================================================================

#pragma mark - 通讯录姓名表视图单元格 延展(工具)
@interface WSContactsBookNameTableViewCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录姓名表视图单元格
@implementation WSContactsBookNameTableViewCell

#pragma mark - 获取iconImageView方法
- (UIImageView *)iconImageView
{
    if(_iconImageView == nil)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.clipsToBounds = YES;
    }
    
    return _iconImageView;
}

#pragma mark - 获取mainTitle方法
- (UILabel *)mainTitle
{
    if (_mainTitle == nil)
    {
        _mainTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _mainTitle.backgroundColor = [UIColor clearColor];
        _mainTitle.textAlignment = NSTextAlignmentLeft;
        _mainTitle.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_standard];
        _mainTitle.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleBlackColor];
        _mainTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _mainTitle;
}

#pragma mark - 获取auxiliaryTitle方法
- (UILabel *)auxiliaryTitle
{
    if (_auxiliaryTitle == nil)
    {
        _auxiliaryTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _auxiliaryTitle.backgroundColor = [UIColor clearColor];
        _auxiliaryTitle.textAlignment = NSTextAlignmentLeft;
        _auxiliaryTitle.font = [UIFont systemFontOfSize:kContactsBookAuxiliaryTitleSize_standard];
        _auxiliaryTitle.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleGrayColor];
        _mainTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _auxiliaryTitle;
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

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.mainTitle];
        [self.contentView addSubview:self.auxiliaryTitle];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutCell];
}

#pragma mark - 设置单元格数据方法 infoData:数据源 isHiddenLine:是否隐藏线标示
- (void)setCellWithData:(WSContactsStandardInfo *)infoData isHiddenLine:(BOOL)isHiddenLine
{
    NSString *urlStr = [[WSContactsBookTools sharedManager] getEffectiveDownloadURL:infoData.headPhoto];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage scaledImageForName:@"headportrait_normal" ofType:@"png"]];
    self.mainTitle.text = ((infoData.name.length > 0) ? infoData.name : @"");
    self.auxiliaryTitle.text = ((infoData.jobTitle.length > 0) ? infoData.jobTitle : @"");
    self.lineView.hidden = isHiddenLine;
    
    [self setNeedsLayout];
}

#pragma mark - 获取单元格高度方法
+ (CGFloat)getCellHeight
{
    return (kContactsBookElementHeight_standard + kContactsBookLineHeight_standard);
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录姓名表视图单元格(工具)
@implementation WSContactsBookNameTableViewCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell
{
    CGFloat maxDrawHeight = CGRectGetHeight(self.contentView.frame) - kContactsBookLineHeight_standard;
    
    CGFloat x = kContactsBookSpace_big;
    CGFloat y = (maxDrawHeight - kContactsBookIconSize_standard) / 2;
    CGFloat w = kContactsBookIconSize_standard;
    CGFloat h = kContactsBookIconSize_standard;
    self.iconImageView.frame = CGRectMake(x, y, w, h);
    self.iconImageView.layer.cornerRadius = kContactsBookIconSize_standard / 2;
    
    x = CGRectGetMaxX(self.iconImageView.frame) + kContactsBookSpace_big;
    y = maxDrawHeight;
    w = CGRectGetWidth(self.contentView.frame) - x;
    h = kContactsBookLineHeight_standard;
    self.lineView.frame = CGRectMake(x, y, w, h);
    
    CGSize mainTitleSize = CGSizeMake(0.0f, 0.0f);
    CGSize auxiliaryTitleSize = CGSizeMake(0.0f, 0.0f);
    CGFloat textDrawHeight = 0.0f;
    if(self.mainTitle.text.length > 0)
    {
        mainTitleSize = [self.mainTitle.text ws_sizeWithFont:self.mainTitle.font constrainedToWidth:2000.0f];
        textDrawHeight = mainTitleSize.height;
    }
    if(self.auxiliaryTitle.text.length > 0)
    {
        auxiliaryTitleSize = [self.auxiliaryTitle.text ws_sizeWithFont:self.auxiliaryTitle.font constrainedToWidth:2000.0f];
        textDrawHeight += ((textDrawHeight > 0) ? (kContactsBookSpace_small + auxiliaryTitleSize.height) : auxiliaryTitleSize.height);
    }
    
    x = CGRectGetMaxX(self.iconImageView.frame) + kContactsBookSpace_big;
    y = (maxDrawHeight - textDrawHeight) / 2;
    w = CGRectGetWidth(self.contentView.frame) - x - kContactsBookSpace_big;
    h = mainTitleSize.height;
    self.mainTitle.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.iconImageView.frame) + kContactsBookSpace_big;
    y = (CGRectGetHeight(self.mainTitle.frame) > 0) ? (CGRectGetMaxY(self.mainTitle.frame) + kContactsBookSpace_small) : ((maxDrawHeight - textDrawHeight) / 2);
    w = CGRectGetWidth(self.contentView.frame) - x - kContactsBookSpace_big;
    h = auxiliaryTitleSize.height;
    self.auxiliaryTitle.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
