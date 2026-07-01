//
//  WinStockOutPopupConfig.h
//  WinSFA
//
//  Created by zzialx on 2025/7/30.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WinInventoryPopupConfig.h"
#import "WSInventoryModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^WinStockOutPopupActionBlock)(void);


@interface WinStockOutPopupConfig : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString * stockOutProdName;

@property (nonatomic, copy) NSString * stockOutProdCount;

@property (nonatomic, copy) NSString *cancelButtonTitle;

@property (nonatomic, strong) NSArray<WSStockOutModel *> *otoTableData;

@property (nonatomic, copy) WinStockOutPopupActionBlock confirmAction;

@property (nonatomic, copy) NSString *confirmButtonTitle;


- (WinStockOutPopupConfig *(^)(NSString *))setTitle;

- (WinStockOutPopupConfig *(^)(NSString *))setStockOutProdName;

- (WinStockOutPopupConfig *(^)(NSString *))setStockOutProdCount;

- (WinStockOutPopupConfig *(^)(NSArray<WSStockOutModel *> *))setOtoTableData;

- (WinStockOutPopupConfig *(^)(NSString *))setCancelButtonTitle;

- (WinStockOutPopupConfig *(^)(NSString *))setConfirmButtonTitle;

- (WinStockOutPopupConfig *(^)(WinStockOutPopupActionBlock))setConfirmAction;


@end

NS_ASSUME_NONNULL_END
