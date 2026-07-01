//
//  WSBaseDataGridComponentDataSource.h
//  WinSFA
//
//  Created by HZH on 17/3/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "DataGridComponent.h"
#import "WSBaseStoreProddisDBService.h"
#import "BaseViewController.h"
#import "WSAcvtModel.h"
#import "WSBaseGridDataSource.h"
#import "WSAcvtGridWithDsAcvtDataSoureTools.h"

@interface WSBaseDataGridComponentDataSource : DataGridComponentDataSource


@property (nonatomic, strong) WSFuncsBean *currentFunc;
@property (nonatomic, strong) WSStoreBean *currentStore;
@property (nonatomic, strong) WSAcvtBean_qst *currentQst;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) WSBaseGridDataSource *gridDataSource;

@property (nonatomic, strong) NSMutableArray *moreProductArray;
@property (nonatomic, assign) NSInteger m_moreProdsCount;
@property (nonatomic, assign) BOOL isNeedShowMoreButton;

@property (nonatomic ,assign) BOOL isValueChange;
@property (nonatomic, copy) NSString *md5;

@property (nonatomic,strong) WSAcvtModel *model;


// 表头包含的checkBox数组
@property (nonatomic, strong) NSMutableArray  *checkBoxesArrayOfHeaderView;

@property (nonatomic, assign) NSInteger lastSelectedSerieProdsCount;

@property (nonatomic, assign) BOOL isClear;// 插入数据库时候是否覆盖以前prodId一样的产品

@property (nonatomic, strong) NSString  *resultCheck;

@property (nonatomic, weak) BaseViewController *ownViewController;

@property (nonatomic, strong) NSArray *m_DataBaseDatas;

@property (nonatomic, strong) NSMutableDictionary *dataSourceCache;

@property (nonatomic, copy) NSString *pType;

@property (nonatomic, copy) NSString *brandId;
//表格是acvt类型时，在这个工具中处理数据源和回显值 2019-11-07
@property (nonatomic, strong) WSAcvtGridWithDsAcvtDataSoureTools *acvtTypeDataSourceTool;

- (id)initWithStore:(WSStoreBean *)aStore func:(WSFuncsBean *)aFunc ownViewController:(BaseViewController *)aViewController andCurrentTableItem:(WSTableItem *)currentTableItem;

- (id)initWithStore:(WSStoreBean *)aStore func:(WSFuncsBean *)aFunc ownViewController:(BaseViewController *)aViewController andCurrentTableItem:(WSTableItem *)currentTableItem andBrandId:(NSString *)brandId;

- (void)initDataSource;

- (NSString *)getGridMd5;

- (NSString *)createGridMD5;

- (NSString *)getCurrentViewServerValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex widgetCacheKey:(NSString *)widgetCacheKey;
- (NSString *)getCurrentNativeValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex widgetCacheKey:(NSString *)widgetCacheKey;
- (NSString *)getCurrentViewIdsValueWith:(WSFuncsBean_Param *)aParam index:(NSInteger)aIndex;

- (void)sortByParam;

- (BOOL)isNeedRepeatProd;

@end
