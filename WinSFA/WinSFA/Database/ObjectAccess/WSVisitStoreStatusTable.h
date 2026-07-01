//
//  WSVisitStoreStatusTable.h
//  WinSFA
//
//  Created by heju on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSVisitStoreStatusTable : WSSqliteUtil

+ (instancetype)shareInstance;

- (void)cleanOldData;

//- (BOOL)insertStatusWithStore:(WSStoreBean *)currentStore funcCode:(NSString *)funcCode  empId:(NSString *)empId;
//
//- (BOOL)updateStatusWithStoreId:(NSString *)storeId funcCode:(NSString *)funCode empId:(NSString *)empId;

- (BOOL)updateStatusWithStore:(WSStoreBean *)currentStore funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status;
- (BOOL)updateStatusWithStore:(WSStoreBean *)currentStore funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status fromModule:(NSString*)fromModule;
- (void)updateStatusWithStoreId:(NSString *)storeId funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status;


- (NSInteger)queryInPlanStoresVisitedCountWithFuncBean:(WSFuncsBean *)funcBean empId:(NSString *)empId biz_date:(NSString *)bizDate;

-(NSString *)queryStatusWithStoreId:(NSString *)storeId;

/// 查询拜访状态表
/// - Parameter storeId: 门店id
+ (WSVisitStoreStatusObject *)queryVisitStoreStatusWithStoreId:(NSString *)storeId;



@end
