//
//  WSBaseStoreOtherDataDBService.h
//  WinSFA
//
//  Created by weida on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDBService.h"

@interface WSBaseStoreOtherDataDBService : WSDBService

+ (void)saveStoreRequestFlagWith:(NSString *)flagType empId:(NSString *)empId storeIdArray:(NSArray *)storeIdArray;
+ (void)saveStoreRequestFlagWith:(NSString *)flagType empId:(NSString *)empId storeId:(NSString *)storeId;

- (BOOL)isStoreRequested:(NSString *)flagType empId:(NSString *)empId storeId:(NSString *)storeId;

+ (void)saveStoreCityCode:(NSString *)cityCode cityName:(NSString *)cityName  empId:(NSString  *)empId bizDate:(NSString *)bizDate;
+ (void)saveStoreCityCode:(NSString *)cityCode cityName:(NSString *)cityName  empId:(NSString  *)empId bizDate:(NSString *)bizDate storeCount:(NSString*)storeCount;
+ (void)saveStoreCityCode:(NSString *)cityCode cityName:(NSString *)cityName  empId:(NSString  *)empId bizDate:(NSString *)bizDate storeCount:(NSString*)storeCount type:(NSString *)type;
+ (void)saveStoreSearchObjCode:(NSString *)searchObjCode flagWith:(NSString *)flagType  empId:(NSString  *)empId funcCode:(NSString *)funcCode;
+ (void)saveStoreSearchObjCode:(NSString *)searchObjCode flagWith:(NSString *)flagType  empId:(NSString  *)empId funcCode:(NSString *)funcCode bizDate:(NSString *)bizDate;
+ (BOOL)saveStoreId:(NSString *)storeId withFc:(NSString *)fc withAcvtId:(NSString *)acvtId withBizDate:(NSString *)bizDate withEmpId:(NSString *)empId genId:(NSString *)genId;

+ (NSString *)queryStoreSearchObjCodeWithFlag:(NSString *)flagType  empId:(NSString *)empId  funcode:(NSString *)funcCode;
/*清除实时搜索门店模块下搜索的'关键字'数据*/
+ (void)clearStoresSearchCodeFlag;

// 使用的 item1 作为查询条件
- (BOOL)insertOrUpdateStoreWithDataDic:(NSDictionary *)dic;

- (BOOL)deleteWithType:(NSString *)type;
- (BOOL)deleteWithStoreId:(NSString *)storeId withFc:(NSString *)fc withAcvtId:(NSString *)acvtId withEmpId:(NSString *)empId;
- (BOOL)deleteWithType:(NSString *)type storeId:(NSString *)storeId item3:(NSString *)item3;
- (void)deleteStoreCityCode:(NSString *)cityCode empId:(NSString  *)empId;
- (void)deleteStoreCityCode:(NSString *)cityCode empId:(NSString  *)empId type:(NSString *)type;
- (void)deleteBySidWithNodeName:(NSString *)nodeName dicts:(NSArray *)dicts storeArray:(NSArray *)storeArray ;
- (BOOL)deleteWithType:(NSString *)type storeId:(NSString *)storeId;

- (NSArray *)queryWithType:(NSString *)type withItem16:(NSString *)item16;
- (NSArray *)queryWithType:(NSString *)type;
- (NSArray *)queryWithItem1:(NSString *)item1;

- (NSArray *)querywithType:(NSString *)type withColName:(NSString *)colName withColValue:(NSString *)colValue;

+ (BOOL)saveFuncTipData:(NSArray *)funcTipArray;
+ (WSBaseStoreOtherDataObject *)queryFuncTipWithFc:(NSString *)fc;
- (NSInteger)getFuncTipCountWithFC:(NSString *)fc storeId:(NSString *)storeId;
- (NSInteger)getWorkCCellFuncTipCountWithFC:(NSString *)fc storeId:(NSString *)storeId type:(NSString*)type;

// SFA-13289 与安卓统一逻辑，新增存储prodspec_img节点数据到base_store_other_data表中的方法
+ (BOOL)saveProdSpecImgData:(NSArray *)dictsArray FromNode:(NSString *)nodeName;
+ (NSArray *)queryProdSpecImg;

+ (WSBaseStoreOtherDataObject *)queryAcvtGenIdWithStoreId:(NSString *)storeId withFc:(NSString *)fc withAcvtId:(NSString *)acvtId withBizDate:(NSString *)bizDate withEmpId:(NSString *)empId;

// YIHAIKERRY-1876 增加保存已请求计划外门店数据的记录
+ (BOOL)saveStoreRequestFlagWithData:(NSArray *)dictsArray FromNode:(NSString *)nodeName;

// SFA-21452
- (NSArray *)queryProductColWithFC:(NSString *)fc;

- (NSArray *)queryProductColWithFC:(NSString *)fc storeId:(NSString*)storeId;


- (NSArray *)queryProductUnit;

// YIHAIKERRY-3214 获取门店筛选
- (NSArray *)queryStoreFilterWithQstArray:(NSArray *)qstArr;

//SFA-24180
- (NSArray *)queryHighFrequencySearchDataWithType:(NSString *)type empId:(NSString *)empId maxCount:(NSInteger)maxCount;//查询高频搜索数据方法
- (void)saveHighFrequencySearchDataWithType:(NSString *)type empId:(NSString *)empId text:(NSString *)text;             //保存高频搜索数据方法
- (void)deleteHighFrequencySearchDataWithType:(NSString *)type empId:(NSString *)empId text:(NSString *)text;           //删除高频搜索数据方法

@end
