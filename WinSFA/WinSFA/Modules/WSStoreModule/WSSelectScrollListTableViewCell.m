//
//  WSSelectScrollListTableViewCell.m
//  WinSFA
//
//  Created by wangzhiwei on 2018/9/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSelectScrollListTableViewCell.h"
#import "PureLayout.h"
#define SCROLL_LIST_CELL_SubView_Font (INTERFACE_IS_PHONE ? 13.0f : 15.0f)
@interface WSSelectScrollListTableViewCell ()
@end
@implementation WSSelectScrollListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSSelectListNewTableviewCellStyle)funcStyle isStoreInfo:(NSString *)isStoreInfo cellWidth:(CGFloat)cellWidth
{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFuncStyle:funcStyle isStoreInfo:isStoreInfo cellWidth:cellWidth];
    
    if (self) {
        userStoreIcon = NO;
        CGFloat codePadding = 7;
        UIView *lineView = [UIView newAutoLayoutView];
        [self.contentView addSubview:lineView];
        [lineView setBackgroundColor:[UIColor colorWithRed:227.0f/255 green:227.0f/255 blue:227.0f/255 alpha:1.0f]];
        [lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeNameLabel withOffset:codePadding];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:MAIN_CELL_PADDING];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:MAIN_CELL_PADDING];
        [lineView autoSetDimension:ALDimensionHeight toSize:MAIN_CELL_SEPERATOR_HEIGHT];
    }
    return self;
    
}
-(void)setStore:(WSStoreBean *)store
{
    [super setStore:store];
    [self addPhoneButton];
    [self resetPhone];
    self.storeNavButton.hidden = YES;
    
}
-(void)addPhoneButton{
    
    [self.phoneButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.addressLabel];
    [storeAddressWidthConstraint autoRemove];
    storeAddressWidthConstraint =  [self.addressLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.phoneButton withOffset:-24.0];
}

- (CGFloat)getTextWidthRatio {
    return INTERFACE_IS_PHONE ? 0.9 : 0.8;
}

-(CGFloat)getStoreAddressLabelWidthIsHaveVisitState:(BOOL)isHaveVisitState presentStoreAddressLabelWidth:(CGFloat)presentStoreAddressLabelWidth
{
    // 如果是已拜访的，优先减拜访按钮宽度
    if(!isHaveVisitState) {
        return presentStoreAddressLabelWidth - MAIN_BUTTON_WH;
    }
    return presentStoreAddressLabelWidth;
}
@end
