//
//  WSFptTable.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSqliteUtil.h"
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSAppData.h"
#import "WSProductTable.h"


@interface WSFptTable : WSSqliteUtil

+ (WSFptTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//插入fpt和product数据
- (void)insertWithFptArray:(NSArray *)fptValues product:(NSArray *)proValues;

//插入fpt和product数据 清除proValues
- (BOOL)insertWithFptArray:(NSArray *)fptValues product:(NSArray *)proValues isClear:(BOOL) isClear;

- (BOOL)deleteProductWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid andProdIds:(NSArray *)prodIds;

//查询fpt数据
- (NSArray *)queryFptWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid;

/*调查问卷嵌表格 查询回显数据*/
- (NSArray *)queryAcvtDataGridPannelProductWithGenId:(NSString *)genId;

//查询Product数据
- (NSArray *)queryProductWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid;


//照片回显
- (NSArray *)queryFptImagePathWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid;

//查询FPT对象
- (WSFptObject *)queryFPTWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid;


/**
 *  ACVT内嵌TB类型产品表格专用查询
 *
 *  @param aStoreId
 *  @param aFc
 *  @param md5
 *
 *  @return
 */
- (WSFptObject *)queryFPTWithStoreIdForTB:(NSString *)aStoreId fc:(NSString *)aFc md5:(NSString *)md5;

@end
