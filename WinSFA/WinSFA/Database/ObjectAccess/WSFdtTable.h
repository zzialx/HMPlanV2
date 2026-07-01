//
//  WSFdtTable.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSqliteUtil.h"
#import "WSStoreBean.h"
#import "WSFuncsBean.h"
#import "WSAppData.h"
#import "WSDictBean.h"
#import "WSDictTable.h"


@interface WSFdtTable : WSSqliteUtil

+ (WSFdtTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//插入Fdt和Dict数据
- (BOOL)insertWithFdtArray:(NSArray *)fdtValues Dict:(NSArray *)dictValues;

/*随访人员*/
- (void)insertWithFdtArray:(NSArray *)fdtValues Dict:(NSArray *)dictValues srid:(NSString *)srid;

//查询fpt数据
- (NSArray *)queryFdtWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc srid:(NSString *)srid;

//查询Product数据
- (NSArray *)queryDictWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc srid:(NSString *)srid withMd5:(NSString *)md5;

//回显照片
- (NSArray *)queryFdtImagePathWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc srid:(NSString *)srid;

@end
