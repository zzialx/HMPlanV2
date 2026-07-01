//
//  WSAddStoreTable.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSAppData.h"
#import "WSSqliteUtil.h"
#import "WSAddStoreTable.h"
#import "WSAddStoreQstTable.h"

@interface WSAddStoreTable : WSSqliteUtil
//
//+ (WSAddStoreTable *)sharedTable;
//
////清除前天数据
//- (void)cleanOldData;
//
//// 查询立即拜访的新增门店
//- (NSArray*)queryImmediatelyVistStore;
//
//// 针对三棵树不能区分经销商和开发商  fucn_code 就是fc
//- (NSArray*)queryStoreByFc:(NSString *)fc;
//
////是否新增
//- (BOOL)isNewStore:(NSString *)storeId;
//
////根据fc和店的id过滤合适的查询条件
//- (NSArray*)queryStoreByFc:(NSString *)fc andStoreId:(NSString *)storeId;
//
//- (NSArray*)queryStoreByStoreId:(NSString *)storeId;
//
//- (NSArray*)queryDataByStoreId:(NSString *)storeId acvtId:(NSString *)acvtId;
//
//- (WSAddStoreObject *)queryAddStoreObjByMd5:(NSString *)md5;
//
//- (void)cleanWithNewData;
//
//- (void)cleanOhterEmpData;

@end
