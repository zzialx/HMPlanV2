//
//  WSAcvtGridWithDsAcvtDataSoureTools.h
//  WinSFA
//
//  Created by zhangmin on 2019/11/7.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//DS_ACVT
//表格是acvt类型，数据源 回显，上传  在此工具中处理
@interface WSAcvtGridWithDsAcvtDataSoureTools : NSObject
@property (nonatomic ,strong) NSArray *acvtArray;

@property (nonatomic ,strong) NSArray *acvtModelArray;

@property (nonatomic, strong) WSFuncsBean               *currentFuncs;

@property (nonatomic, strong) WSStoreBean               *currentStore;


@property (nonatomic, strong) NSMutableArray    *m_DataBaseDatas;
@property (nonatomic, strong) NSMutableArray    *m_dataSources;
@property (nonatomic, strong) NSMutableArray    *moreProductArray;
@property (nonatomic, assign) NSInteger               m_moreProdsCount;
@property (nonatomic, strong) NSMutableDictionary *formulaDictionary;
@property (nonatomic, strong) NSMutableDictionary *abnormalReasonDict;
@property (nonatomic, strong) NSMutableArray *resonButtons;
@property (nonatomic, assign) BOOL isValueChange;
@property (nonatomic, strong) NSMutableDictionary  *acvtGrid_cacheDataMDictionary;


//init 方法 qst转params
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;
- (NSObject *)getResultDirectly;

#pragma mark - 上传数据
- (BOOL)uploadAcvtGridDataWithGridWidgetsArray:(NSArray *)gridWidgetsArray;
- (BOOL)uploadGridWidgetsArray:(NSArray *)gridWidgetsArray;
@end

NS_ASSUME_NONNULL_END
