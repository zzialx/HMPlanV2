//
//  WSAcvtDataGridViewPanel.h
//  WinSFA
//
//  Created by yang on 15/4/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "WSGridSearchView.h"
#import "WSAcvtDataGridComponentView.h"
#import "WSScanListViewController.h"
@protocol DataGridComponentDelegate,WSAcvtDataGridComponentDataSourceDelegate;
@class DataGridComponent,WSAcvtDataGridComponentDataSource;

@interface WSAcvtDataGridViewPanel : WSWidget <DataGridComponentDelegate,WSAcvtDataGridComponentDataSourceDelegate>

@property (nonatomic, strong) UIView *acvtGridSteadyTableHeadView;              //问卷表格固定头视图
@property (nonatomic, strong) WSAcvtDataGridComponentView *dataGridView;        //表格视图
@property (nonatomic, assign) BOOL isAddedMoreProduct;
@property (nonatomic, strong) WSScanListViewController *scanListViewController;

///**
// *FAC（acvt）界面中的FPT（prod）和FDT（dict）上传的数据中需要加上FAC界面的MD5标识
// **/
//- (void)uploadWithAcvtMD5:(NSString *)acvtMD5 andId:(NSString *)idMD5;
//
- (WSAcvtDataGridComponentDataSource *)getAcvtDataSource;

- (void)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)text  col:(NSString *)parmCol;

- (void)setTableColByOtherTableCol:(NSString *)otherTableParmCol funcCode:(NSString *)funcCode  acvtQstCode:(NSString *)acvtQstCode;

- (void)reloadCurrentWidgetWithValue:(NSObject *)value dis:(NSArray *)dis;


- (NSString *)callGridMethodWithParams:(NSString *)params;

- (NSString *)callGridMethodWithRowId:(NSString *)rowId col:(NSString *)colName methodName:(NSString *)methodName param:(NSString *)param;

/*
prodMap格式: prod_id,20@item9,13@|prod_id,21@item9,12@|
 */
- (void)addProd:(NSString *)prodMap;
// 参数有可能是上面的prodMap格式，也可能是all（表示全部）
- (void)delProd:(NSString *)params;

- (void)addGridRows:(NSString *)params;

- (void)addMoreProdsWithParam:(id)param andVCName:(NSString *)VCName;

// MN-1887 新增隐藏表头的脚本方法
- (void)setHideTableHeader:(NSString *)isHide;


@end
