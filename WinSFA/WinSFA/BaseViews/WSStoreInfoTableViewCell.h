//
//  WSStoreInfoTableViewCell.h
//  WinSFA
//
//  Created by xiajl on 14-10-31.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSBaseTableViewCell.h"

@class WSAcvtListDataItem;

typedef enum{
    WSStoreInfoTableViewCellStyleDefault,   // only top
    WSStoreInfoTableViewCellStyleValue1,	// top, bottom
    WSStoreInfoTableViewCellStyleValue2,    // top, bottom, right
    WSStoreInfoTableViewCellStyleValue3     // top, right
}WSStoreInfoTableViewCellStyle;



@interface WSStoreInfoTableViewCell : WSBaseTableViewCell


@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLable;
@property (nonatomic, strong) UILabel *rightLable;
@property (nonatomic, strong) UILabel *leftLable;
@property (nonatomic, assign) BOOL isShowActionTip;
@property (nonatomic, strong) UILabel *eventCountLabe;
@property (nonatomic, strong) UIImageView *leftIcon;
@property (nonatomic, strong) NSString *leftIconUrl;

/**
 *  @author weida
 *
 *  @brief 是否已经拜访，如果拜访了显示拜访标记
 */
@property (nonatomic,assign) BOOL  isVisited;
@property (nonatomic, assign)BOOL isNotRead;

@property (nonatomic, assign)BOOL readonly;

- (void)setData:(WSAcvtListDataItem *)acvtItem;

+ (CGFloat)cellHeightWithMainTitle:(NSString *)mainTitle rightTitle:(NSString *)rightTitle subTitle:(NSString *)subTitle  leftTitle:(NSString *)leftTitle tableWidth:(CGFloat)tableWidth isShowActionTip:(BOOL)isShowActionTip isNotRead:(BOOL)isNotRead isShowLeftIcon:(BOOL)show;

@end
