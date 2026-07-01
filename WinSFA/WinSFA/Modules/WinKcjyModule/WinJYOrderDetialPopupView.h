//
//  WinJYOrderDetialPopupView.h
//  WinSFA
//
//  Created by zzialx on 2025/7/10.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinInventoryPopupConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface WinJYOrderDetialPopupView : UIView

// 类方法显示弹框
+ (void)showWithConfig:(WinInventoryPopupConfig *)config;

// 隐藏弹框
+ (void)dismiss;


@end

NS_ASSUME_NONNULL_END
