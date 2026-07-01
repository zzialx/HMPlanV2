//
//  WSHelpSalesAlertView.h
//  WinSFA
//
//  Created by zzialx on 2025/5/7.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSHelpSalesViewConfig.h"
#import "WSHelpSalesHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSHelpSalesAlertView : UIView


/// 显示助销alertView
/// - Parameters:
///   - superview: 父view
///   - config: 配置信息
///   - callback: 回调
+ (WSHelpSalesAlertView *)showHelpSalesViewInView:(UIView *)superview
                            config:(WSHelpSalesViewConfig *(^)(void))config
                          callback:(WSHelpSalesAlertViewCallBack)callback tipsCallBack:(WSHelpSalesTipsCallBack)tipsBack;


/// 隐藏自定义注销alertView
/// - Parameter emptyView:
+ (void)hiddenEmptyView:(WSHelpSalesAlertView *)emptyView;


@end

NS_ASSUME_NONNULL_END
