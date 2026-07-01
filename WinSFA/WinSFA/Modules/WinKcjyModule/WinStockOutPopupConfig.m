//
//  WinStockOutPopupConfig.m
//  WinSFA
//
//  Created by zzialx on 2025/7/30.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WinStockOutPopupConfig.h"

@implementation WinStockOutPopupConfig

#pragma mark - 链式配置方法
- (WinStockOutPopupConfig *(^)(NSString *))setTitle {
    return ^WinStockOutPopupConfig *(NSString *title) {
        self.title = title;
        return self;
    };
}

- (WinStockOutPopupConfig *(^)(NSString *))setStockOutProdName {
    return ^WinStockOutPopupConfig *(NSString *stockOutProdName) {
        self.stockOutProdName = stockOutProdName;
        return self;
    };
}


- (WinStockOutPopupConfig *(^)(NSString *))setStockOutProdCount {
    return ^WinStockOutPopupConfig *(NSString *stockOutProdCount) {
        self.stockOutProdCount = stockOutProdCount;
        return self;
    };
}
- (WinStockOutPopupConfig *(^)(NSArray<WSStockOutModel *> *))setOtoTableData {
    return ^WinStockOutPopupConfig *(NSArray<WSStockOutModel *> *otoTableData) {
        self.otoTableData = otoTableData;
        return self;
    };
}
- (WinStockOutPopupConfig *(^)(NSString *))setCancelButtonTitle {
    return ^WinStockOutPopupConfig *(NSString *cancelButtonTitle) {
        self.cancelButtonTitle = cancelButtonTitle;
        return self;
    };
}
- (WinStockOutPopupConfig *(^)(NSString *))setConfirmButtonTitle {
    return ^WinStockOutPopupConfig *(NSString *confirmButtonTitle) {
        self.confirmButtonTitle = confirmButtonTitle;
        return self;
    };
}
- (WinStockOutPopupConfig *(^)(WinStockOutPopupActionBlock))setConfirmAction {
    return ^WinStockOutPopupConfig *(WinStockOutPopupActionBlock confirmAction) {
        self.confirmAction = confirmAction;
        return self;
    };
}
@end
