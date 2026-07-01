//
//  WSCharMessageCell.h
//  WinSFA
//
//  Created by LIBB on 16/12/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseTableViewCell.h"
#import "WSMsgData.h"

@interface WSCharMessageCell : WSBaseTableViewCell

@property(nonatomic,strong) UIImageView *storeIcon;    // 门店icon

@property(nonatomic,strong) UILabel *storeNameLabel;   // 门店名称

@property(nonatomic,strong) UILabel *messageLabel;     //最后聊天记录

@property(nonatomic,strong) UILabel *messageTimeLabel; //消息时间

@property(nonatomic,strong) UILabel * MesNumLable;     //未读消息条数

@property(nonatomic,strong) WSMsgData * msgData; // 门店数据

@property(nonatomic,assign) BOOL isCornerRadius; // 头像是否需要剪切
+ (CGFloat )heightForRowWithStore:(WSMsgData *)store  cellWidth:(CGFloat)cellWidth;


@end
