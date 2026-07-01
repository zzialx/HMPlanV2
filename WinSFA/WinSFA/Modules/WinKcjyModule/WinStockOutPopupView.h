//
//  WinStockOutPopupView.h
//  WinSFA
//
//  Created by zzialx on 2025/7/30.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinStockOutPopupConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface WinStockOutPopupView : UIView

// 类方法显示弹框
+ (void)showStockOutPopupViewWithConfig:(WinStockOutPopupConfig *)config;

// 隐藏弹框
+ (void)dismiss;


@end

NS_ASSUME_NONNULL_END
