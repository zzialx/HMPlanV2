//
//  WSDropListCell.m
//  WinSFA
//
//  Created by yang on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDropListCell.h"
#import "WidgetConstant.h"
#import "WSRequestHelper.h"

@implementation WSDropListCell
{
    NSString *_selectImg;
    NSString *_selectNoImg;
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupViewsWithIsMultiChoice:NO];
        return self;
    }
    return nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isMultiChoice:(BOOL)isMultiChoice
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupViewsWithIsMultiChoice:isMultiChoice];
        return self;
    }
    return nil;
}

- (void)setupViewsWithIsMultiChoice:(BOOL)isMultiChoice {
    self.backgroundColor = [UIColor clearColor];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, 0, self.bounds.size.width - MAIN_PADDING - MAIN_CELL_BUTTON_WH, self.bounds.size.height)];
    self.contentLabel.font = [UIFont systemFontOfSize:UI_Font];
    self.contentLabel.textColor = [self getNormalTitleColor];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.adjustsFontSizeToFitWidth = YES;
    self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.contentLabel.backgroundColor = [UIColor clearColor];
    
    //        self.markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - CHECK_LIST_CELL_HEIGHT - 5, (self.bounds.size.height - CHECK_LIST_CELL_HEIGHT)/2, CHECK_LIST_CELL_HEIGHT, CHECK_LIST_CELL_HEIGHT)];
    //        self.markImageView.contentMode = UIViewContentModeCenter;
    //        self.markImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    //        self.markImageView.backgroundColor = [UIColor clearColor];
    
    self.selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - MAIN_CELL_BUTTON_WH, 0, MAIN_CELL_BUTTON_WH, MAIN_CELL_BUTTON_WH)];
    self.selectedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    if (!isMultiChoice) {
        _selectImg = @"selected_yes_radio";
        _selectNoImg = @"selected_no_radio";
    } else {
        _selectImg = @"icn_check";
        _selectNoImg = @"icn_nocheck";

    }
    [self setSelectedImageViewSelect:NO];
    self.selectedImageView.contentMode = UIViewContentModeCenter;


    self.iconImageView = [[UIImageView alloc] init];
    [self.iconImageView setHidden:YES];
    
    [self.contentView addSubview:self.contentLabel];
    //        [self.contentView addSubview:self.markImageView];
    [self.contentView addSubview:self.selectedImageView];
    [self.contentView addSubview:self.iconImageView];
    
    self.isResetColor = YES;
}

- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem isSelected:(BOOL)isSelected
{
    self.dataItem = dataItem;
    
    if ([dataItem isKindOfClass:[WSStoreBean class]]) {
        WSStoreBean *storeBean = (WSStoreBean *)dataItem;
        if (storeBean.code.length > 0) {
            self.contentLabel.text = [NSString stringWithFormat:@"%@-%@", storeBean.code, storeBean.name];
        }else
            self.contentLabel.text = storeBean.name;
    }else
        self.contentLabel.text = [dataItem getDataItemName];
    
    [self setSelectedIdentify:isSelected];
    
    if ([[dataItem getDataItemID] isEqualToString:kCancelItemId])
    {
        self.contentLabel.textColor = [UIColor lightGrayColor];
        [self setSelectedImageViewSelect:NO];
    }
    
    if ([dataItem isKindOfClass:[WSAcvtBean_qst_opt class]])
    {
        NSString *picUrl = [dataItem getDataItemPic];
        if (picUrl && picUrl.length > 0)
        {
            CGFloat imageWH = 20;
            [self.iconImageView setFrame:CGRectMake(MAIN_PADDING, (self.bounds.size.height - imageWH) / 2, imageWH, imageWH)];
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:picUrl] imageView:self.iconImageView];
            [self.iconImageView setHidden:NO];
            
            CGFloat x = CGRectGetMaxX(self.iconImageView.frame) + MAIN_PADDING;
            [self.contentLabel setFrame:CGRectMake(x, 0, self.bounds.size.width - MAIN_CELL_BUTTON_WH - x, self.bounds.size.height)];
        }
        else
        {
            [self.iconImageView setHidden:YES];
            [self.contentLabel setFrame:CGRectMake(MAIN_PADDING, 0, self.bounds.size.width - MAIN_PADDING - MAIN_CELL_BUTTON_WH, self.bounds.size.height)];
        }
    }
}

- (UIColor *)getNormalTitleColor
{
    UIColor *color = [UIColor colorForKey:@"DropListCellNormalTitleColor"];
    if (!color) {
        color = MAIN_TEXT_COLOR;
    }
    return color;
}

- (UIColor *)getSelectedTitleColor
{
    UIColor *color = [UIColor colorForKey:@"DropListCellSelectedTitleColor"];
    if (!color) {
        color = MAIN_TEXT_COLOR;
    }
    return color;
}

- (UIColor *)getSelectedCellBackgroundColor
{
    UIColor *color = [UIColor colorForKey:@"DropListCellSelectedBackgroudColor"];
    if (!color) {
        color = MAIN_CELL_SELECTED_COLOR;
    }
    return color;
}

- (void)setSelectedIdentify:(BOOL)isSelected {
    if (isSelected) {
        if (self.isResetColor) {
            self.contentView.backgroundColor = [self getSelectedCellBackgroundColor];
            self.contentLabel.textColor = [self getSelectedTitleColor];
        }
    }
    else{
        if (self.isResetColor) {
            self.contentView.backgroundColor = [UIColor clearColor];
            self.contentLabel.textColor = [self getNormalTitleColor];
        }
    }
    [self setSelectedImageViewSelect:isSelected];
}
//修改选中未选中图片 MSTD-7475 董宏 修改 18年1月15日 需求更改
- (void)setSelectedImageViewSelect:(BOOL)imgSelect
{
    if(imgSelect)
        self.selectedImageView.image = [UIImage imageNamed:_selectImg];
    else
        self.selectedImageView.image = [UIImage imageNamed:_selectNoImg];

}
@end
