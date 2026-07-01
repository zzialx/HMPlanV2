//
//  WSNewStoreListTool.h
//  WinSFA
//
//  Created by sunhf on 2018/1/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSNewTodayVisitAndAllStoreCell.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSInoutStoreTable.h"
#import "WSFuncsBeanArray.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSStoreDataProcessService.h"

@interface WSNewStoreListTool : NSObject
#pragma mark - 获得门店准备状态
+ (WSNewStorePrepareState)getStorePrepareStateByStore:(WSStoreBean *)store withWSAcvtBean:(WSAcvtBean *)prepareStateAcvtBean;

#pragma mark - 判断是否有正在拜访中没离店的
+ (BOOL)anyStoreHasNotLeave:(WSStoreBean*)aStore andModuleFC:(NSString *)store_moduleFC withCurrentFuncs:(WSFuncsBean *)currentFuncs;

#pragma mark - 判断当天是否已经拜访过该门店
+ (BOOL)isVisitedStore:(WSStoreBean *)aStore withCurrentFuncs:(WSFuncsBean *)currentFuncs;

#pragma mark - 获得计划外门店的fb
+ (WSFuncsBean*)getSelectedOutPlanFuncsBeanWithStore:(WSStoreBean *)store;

#pragma mark - 判断计划外是否请求过数据
+ (BOOL)isOutPlanRequestWithSubempstoreBean:(WSSubempstoreBean *)subempStore withCurrentStore:(WSStoreBean *)currentStore;

#pragma mark - 处理更新计划内门店数据库中的相关数据
+ (void)saveInPlanStoreRequestFlagWithSubempStore:(WSSubempstoreBean *)subempStore withCurrentStore:(WSStoreBean *)currentStore withStoreDicInfo:(NSDictionary *)storeDicInfo;

#pragma mark - 获得已经离店完成拜访的个数
+ (NSInteger)getCount:(NSArray *)storeListArray withVisitActionStatus:(VisitActionStatus)visitActionStatus;
@end
