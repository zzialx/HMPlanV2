//
//  WSContactsBookDepartmentTableViewCell.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDepartmentTableViewCell.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录部门表视图单元格 延展(内部)
@interface WSContactsBookDepartmentTableViewCell ()

@property (nonatomic, strong) UILabel *mainTitle;       //主标题
@property (nonatomic, strong) UIImageView *arrowImage;  //箭头视图
@property (nonatomic, strong) UIView *lineView;         //线视图

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门表视图单元格 延展(工具)
@interface WSContactsBookDepartmentTableViewCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门表视图单元格
@implementation WSContactsBookDepartmentTableViewCell

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

#pragma mark - 获取arrowImage方法
- (UIImageView *)arrowImage
{
    if(_arrowImage == nil)
    {
        _arrowImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImage.backgroundColor = [UIColor clearColor];
        _arrowImage.contentMode = UIViewContentModeScaleAspectFit;
        _arrowImage.image = [UIImage scaledImageForName:@"contactsBookDetailsArrow" ofType:@"png"];
    }
    return _arrowImage;
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
        [self.contentView addSubview:self.mainTitle];
        [self.contentView addSubview:self.arrowImage];
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
    self.mainTitle.text = ((infoData.name.length > 0) ? infoData.name : @"");
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

#pragma mark - 通讯录部门表视图单元格 延展(工具)
@implementation WSContactsBookDepartmentTableViewCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell
{
    CGFloat maxDrawHeight = CGRectGetHeight(self.contentView.frame) - kContactsBookLineHeight_standard;
    UIImage *image = [UIImage scaledImageForName:@"contactsBookDetailsArrow" ofType:@"png"];
    
    CGFloat x = kContactsBookSpace_big;
    CGFloat y = maxDrawHeight;
    CGFloat w = CGRectGetWidth(self.contentView.frame) - x;
    CGFloat h = kContactsBookLineHeight_standard;
    self.lineView.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetWidth(self.contentView.frame) - image.size.width - kContactsBookSpace_big;
    y = (CGRectGetHeight(self.contentView.frame) - image.size.height) / 2;
    w = image.size.width;
    h = image.size.height;
    self.arrowImage.frame = CGRectMake(x, y, w, h);
    
    x = kContactsBookSpace_big;
    y = 0.0f;
    w = CGRectGetMinX(self.arrowImage.frame) - kContactsBookSpace_big - x;
    h = CGRectGetHeight(self.contentView.frame);
    self.mainTitle.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
