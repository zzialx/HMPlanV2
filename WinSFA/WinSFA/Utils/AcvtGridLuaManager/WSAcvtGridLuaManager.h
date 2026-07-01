//
//  WSAcvtGridLuaManager.h
//  WinSFA
//
//  Created by Alicia on 2018/10/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtDataGridComponentDataSource.h"

@interface WSAcvtGridLuaManager : NSObject


- (instancetype)initWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource;

#pragma mark - callGridMethodWithParams

- (NSString *)getGridRowIdAndNameArrayWithRowId:(NSString *)rowId col:colName param:(NSString *)qstCode;

- (NSString *)getGridRowIdArrayWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)qstCode;

- (NSString *)getGridCellKeyAndValueArrayWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)paramStr;

- (NSString *)getValueWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (NSString *)getValuePresentationWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (NSString *)getColNameWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (NSString *)getFillRowCountWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (void)setValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;

- (NSString *)gridViewHasValueWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (void)setMaxValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;

- (void)setMinValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;

- (void)setReadOnlyWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;
- (void)setReadonlyWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;

- (NSString *)checkRowRequireWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (void)setTextColorWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)colorHexString;

- (void)setItemTitleColorWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (void)setItemTitleBackgroundColorWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (void)addTitleStartFlagWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (void)setRequestWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)param;

- (NSString *)getRowNameByProdIdWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (NSString *)getPromotionGiftWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)sql;

- (NSString *)getCurrentTabOperationRowIdWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

- (NSString *)computeColSumWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;

#pragma mark - AcvtDataGridViewPanel Lua method

- (NSString *)getGridCellKeyAndValueArrayByColName:(NSString *)colName;

- (NSString *)getSelectedProductId;

- (void)setSelectedProductId:(NSString *)params;

- (NSString *)getTableColValueByProId:(NSString *)prodId col:(NSString *)parmCol;

- (void)setTableColValueFromDataSourceByProId:(NSString *)prodId textValue:(NSString *)value col:(NSString *)paramCol;

- (void)setTableColValueFromDataSourceByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode acvtQstCode:(NSString *)acvtQstCode;

- (NSString *)getColMaxValueInTableByItem:(NSString *)item;

- (double)getSumByExpression:(NSString *)tableExpression;

- (NSString *)computeRowAndColSumWith:(NSString *)prodNames item:(NSString *)columnItem;

- (void)setColDefaultValueWithColName:(NSString *)colName index:(NSInteger)index;

- (void)setMaxMinValue:(NSString *)params;
@end
