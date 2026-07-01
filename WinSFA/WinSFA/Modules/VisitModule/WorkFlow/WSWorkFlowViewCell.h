//
//  WSWorkFlowViewCell.h
//  WinSFA
//
//  Created by Alicia on 2018/1/22.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDICATOR_ICON_WIDTH    20.0f
//MMSH-3505
//[SFA玛氏中国MWC]门店拜访中拜访过的菜单显示的勾太小
#define FUNCS_ICON_WIDTH        (INTERFACE_IS_PHONE ? SCREEN_WIDTH * 0.090 : 24)
#define WORKFLOW_CELL_DEFAULT_HEIGHT (INTERFACE_IS_PAD ? 55.0f : 44.0f)
#define kTitleHeight            20
#define kStatusImageViewWidth   17.0f


@interface WSWorkFlowViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView  *funcsIconImageView;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView  *visitActionImageView;
@property (nonatomic, strong) UIImageView *warningImageView;

- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean
                       store:(WSStoreBean *)store
           visitActionStatus:(VisitActionStatus)visitActionStatus
                      action:(WSVisitStoreActionObject *)action
                     hasTips:(BOOL)hasTips
                  badgeCount:(NSInteger)badgeCount
                   indexPath:(NSIndexPath *)indexPath
                  totalCount:(NSInteger)totalCount;


- (void)setBackgroundBySelected:(BOOL)selected;

@end
