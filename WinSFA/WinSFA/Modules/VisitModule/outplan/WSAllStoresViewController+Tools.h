//
//  WSAllStoresViewController+Tools.h
//  WinSFA
//
//  Created by zzialx on 2025/5/20.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSAllStoresViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSAllStoresViewController (Tools)

/// 进入助销模块
- (void)gotoHelpSalesMoudleWithStore:(WSStoreBean*)store;

/// 结束编辑
- (void)endEdit;

@end

NS_ASSUME_NONNULL_END
