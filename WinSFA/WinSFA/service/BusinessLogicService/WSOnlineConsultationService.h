//
//  WSOnlineConsultationService.h
//  WinSFA
//
//  Created by HZH on 2017/12/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSOnlineConsultationService : NSObject

+ (instancetype)shareInstance;

// SFA-15431 跳转在线咨询页面，不一定是点击悬浮窗，也可能是点击九宫格菜单跳转
- (void)gotoNextOnlineConsultationReportFormViewControllerWithOnlineConsultationString:(NSString *)onlineConsultationString;

//YIHAIKERRY-4217 2018-09-28
+ (NSString *)rebuildOnlineConsultationUrlStringWithUrl:(NSString *)url;

@end
