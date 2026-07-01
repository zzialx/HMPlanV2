//
//  WSVisitStorePlanTable.h
//  WinSFA
//
//  Created by zhangke on 14-5-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSVisitStorePlanTable : WSSqliteUtil


+ (WSVisitStorePlanTable *)sharedTable;

//插入数据
- (void)insertVisitStorePlanWithDic:(NSDictionary *)valueDic;

- (void)insertVisitStorePlanWithStoreInfoDic:(NSDictionary *)infoDic;

- (BOOL)batchInsertVisitStorePlanWithStoreInfoArray:(NSArray *)array;

//根据日期查询
- (NSArray *)queryVisitStorePlanByDate:( NSString*)date;

- (NSArray *)queryVisitStorePlanByDate:( NSString*)date withStoreId:(NSString *)storeId;

- (NSInteger)queryVisitStorePlanCountByDate:(NSString*)date withStoreIds:(NSString *)storeIds;

- (void)deletVisitStorePlanWithByDate:(NSString *)date withStoreId:(NSString *)storeId;

- (void)deletVisitStorePlanWithByDate:(NSString *)date;

@end
