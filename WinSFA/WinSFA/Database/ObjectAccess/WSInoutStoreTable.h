//
//  WSInoutStoreTable.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSAppData.h"

typedef enum {
    EParameterType_NULL,
    EParameterType_ParentFC,
    EParameterType_VisitId
} EParameterType;



@interface WSInoutStoreTable : WSSqliteUtil

+ (WSInoutStoreTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

// 判断是否进入过本店
- (BOOL)isEnterStore:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

// 判断是否离开本店
- (BOOL)isLeaveStore:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

-(BOOL) isEnterAndLeaveStore:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

//某家未离店数据
- (WSInoutStoreObject *)anyStorehaveNotLeave;

//根据门店id和moduleFC获取未离店记录
-(WSInoutStoreObject*)getNotLeaveStoreByStoreId:(NSString *)storeId moduleFc:(NSString *)moduleFc;

//获取进店时间
- (NSString *)getEnterStoreTime:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

//获取离店时间
- (NSString *)getLeaveStoreTime:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

//更新离店时间
-(void)updateLeaveStoreTime:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

-(void)updateLeaveStoreTime:(NSString*)storeId andOtherParam:(NSString *)parameter;

//更新离店时间（不是进店时间）
-(void)updateLeaveStoreTime:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType outTime:(NSString*)outTime;

//查询拜访过的门店的storeId数组
- (NSArray *)queryVisitedStoreIdArray;

//获取门头照
- (NSString *)getStoreLocalImageWithStore:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;

//强制更新离店方法
- (void)forceUpdateLeaveStoreWithStore:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType;
//记录强制离店方法
- (void)setForceLeaveStoreWithStore:(WSStoreBean *)store;
//获取强制离店方法
- (BOOL)isForceLeaveStoreWithStore:(WSStoreBean *)store;
//清除全部强制离店数据方法
- (void)clearAllForceLeaveStore;


//查询当前节点的父节点的所有字节点的funcode
- (NSString*)queryFunCodeListWithCurrentFunCode:(NSString*)currentFunCode;
@end
