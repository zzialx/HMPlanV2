//
//  WCBaseViewController+Tools.h
//  WinSFA
//
//  Created by zzialx on 2023/7/27.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"


typedef void(^handlerSuccess)(void);

NS_ASSUME_NONNULL_BEGIN

@interface WCBaseViewController (Tools)

/// 退出登录
- (void)loginOutApp;

/// 清楚缓存
- (void)clearAppDataSuccess:(handlerSuccess)block;

@end

NS_ASSUME_NONNULL_END
