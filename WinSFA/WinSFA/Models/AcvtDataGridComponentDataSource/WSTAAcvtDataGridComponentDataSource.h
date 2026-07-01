//
//  WSTAAcvtDataGridComponentDataSource.h
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "DataGridComponent.h"

#import "WSAcvtModel.h"

#import "DataGridComponent.h"

#import "WSFuncsBean_opt.h"

#import "WSAcvtBean_qst.h"

#import "WSTableItem.h"

#import "WSAppData.h"

#import "WSFuncsBean.h"

#import "WSTableItemsArray.h"

#import "PhotoTypeButton.h"

#import "WSAddNewAcvtModel.h"

#import "WSSelectListView.h"

@protocol WSTAAcvtDataGridComponetDataSourceDelegate;

@class WSStoreAcvtDisArray ;
@interface WSTAAcvtDataGridComponentDataSource : DataGridComponentDataSource<UITextFieldDelegate,PhotoTypeButtonDelegate,ZJPSelectListDelegate>


@property (nonatomic, strong)NSObject<I_W_BuildInfo> *currentBuildInfo;

@property (nonatomic, strong)WSAddNewAcvtModel *acvtModel;

@property (nonatomic, strong)WSFuncsBean *currentFunc;

@property (nonatomic, strong)NSArray *qstsForColumn;

@property (nonatomic, strong)NSMutableArray *dataSource;

@property (nonatomic, strong)NSMutableArray *columnParams;

@property (nonatomic, strong)NSMutableArray *columnWidths;

@property (nonatomic, strong)NSArray *dbDataSource;

@property (nonatomic, strong)WSAcvtBean *relationAcvtBean;

@property (nonatomic, strong )WSStoreAcvtDisArray *acvtDisArray;

@property (nonatomic, assign)id <WSTAAcvtDataGridComponetDataSourceDelegate> taDataSourceDelegate;

@property (nonatomic, strong) NSMutableDictionary *nativeGridViewValuesMapping;

- (id)initWith:(NSObject <I_W_BuildInfo> *)currentBuildInfo;
// 实时请求的数据,节点名称和当前构建信息
- (id)initWith:(NSObject<I_W_BuildInfo> *)currentBuildInfo withNowRequestData:(NSObject *)tmpData andRequestNodeName:(NSString *)nodeName ;
- (NSString *)getGridMd5;

@end

@protocol WSTAAcvtDataGridComponetDataSourceDelegate <NSObject>

- (void)taAcvtDataGridComponetDataSource:(WSTAAcvtDataGridComponentDataSource *)taDataSource valueChange:(NSObject *)object;

@end




