//
//  WSBaseMainViewController.h
//  WinSFA
//
//  Created by yang on 2017/7/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@interface WSBaseMainViewController : WCBaseViewController

@property (nonatomic, strong) NSTimer *noticeTimer;


// 信息中心定时更新公告信息
- (void)updateNoticeInfo;
- (void)updateNoticeInfoRequestStart;


- (void)resetNoticeInfoBadge:(NSArray *)msgArray;//子类实现


- (void)reloadFunTipCount; //子类实现，刷新环信CMD消息设置的角标


@end
