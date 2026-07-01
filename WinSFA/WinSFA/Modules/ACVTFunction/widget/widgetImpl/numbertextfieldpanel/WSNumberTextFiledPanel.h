//
//  WSNumberTextFiledPanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTextFiledPanel.h"
#import "I_M_ViewDelegate.h"

@interface WSNumberTextFiledPanel : WSTextFiledPanel<I_M_ViewDelegate>

@property (nonatomic, assign) BOOL isfillAll;  //是否布局满  默认NO 留空白。 yes为左右不留白
@end
