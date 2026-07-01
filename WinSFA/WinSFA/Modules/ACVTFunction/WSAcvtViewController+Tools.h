//
//  WSAcvtViewController+Tools.h
//  WinSFA
//
//  Created by zzialx on 2025/7/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSAcvtViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GoBackBlock)(void);

@interface WSAcvtViewController (Tools)

/// 显示库存建议订单alertView
- (void)showInventoryAlertViewWithResultDic:(NSDictionary*)resultDic withNotifyId:(NSString *)aNotifyId complete:(GoBackBlock)complete;

@end

NS_ASSUME_NONNULL_END
