//
//  WSFacTable.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSqliteUtil.h"
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSHosBean.h"

#import "WSAppData.h"
#import "WSFacQstTable.h"


@interface WSFacTable : WSSqliteUtil
//
//+ (WSFacTable *)sharedTable;
//
////清除前天数据
//- (void)cleanOldData;
//
////插入Fac和Qst数据
//- (BOOL)insertWithFacArray:(NSArray *)Values Qst:(NSArray *)qstValues;
//
////回显QST
//-(NSArray*)queryAcvtInfo:(WSStoreBean *)store acvtNewStore:(WSStoreBean *)acvtNewStore Funcs:(WSFuncsBean *)funcs AcvtId:(NSString *)acvtid;
////回显QST2
//-(NSArray*)queryAcvtInfo:(id)store acvtNewStore:(WSStoreBean *)acvtNewStore Funcs:(WSFuncsBean *)funcs AcvtId:(NSString *)acvtid andMD5:(NSString *)md5;
//
////照片回显
//-(NSArray*)queryAcvtImagePathInfo:(WSStoreBean*)store Funcs:(WSFuncsBean*)funcs AcvtId:(NSString*)acvtid;
//
//
//-(NSArray*)queryAcvtInfo:(WSStoreBean*)store Funcs:(WSFuncsBean*)funcs NestedAcvtId:(NSString*)acvtid andParentGenId:(NSString *)pgenId;
//
//-(NSArray*)queryAcvtInfo:(WSStoreBean*)store Funcs:(WSFuncsBean*)funcs NestedAcvtId:(NSString*)acvtid ;
//
////上传后用acvt的 MD5 set 嵌套问卷 storeid  where storeid = new 的记录
//-(BOOL)upadteAcvtInfo:(WSFuncsBean*)funcs andStoreId:(NSString *)storeId NestedAcvtId:(NSString*)acvtid;
//
////删除storeid的值为new数据
//-(BOOL)deleteAcvtInfo:(WSFuncsBean*)funcs NestedAcvtId:(NSString*)acvtid;
//
////用服务器返回的storeid值更新storeid = md5 的记录
//-(BOOL)upadteAcvtInfo:(NSString *)md5 andStoreId:(NSString *)storeId;
//
//-(NSArray*)queryAcvtInfoWithMD5:(NSString *)md5 Funcs:(WSFuncsBean*)funcs  AcvtId:(NSString*)acvtid;
@end
