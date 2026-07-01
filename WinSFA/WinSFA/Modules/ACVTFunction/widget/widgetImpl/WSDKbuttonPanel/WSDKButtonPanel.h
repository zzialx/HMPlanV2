//
//  WSDKButtonPanel.h
//  WinSFA
//
//  Created by mac on 17/8/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWidget.h"

@interface WSDKButtonPanel : WSWidget

// MSTD-6045 添加脚本倒计时方法，暂用于脚本调用
- (void)setRange:(NSString *)timeRange;


@end
