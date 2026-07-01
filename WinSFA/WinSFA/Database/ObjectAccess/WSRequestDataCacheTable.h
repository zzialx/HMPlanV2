//
//  WSRequestDataCacheTable.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-1.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSqliteUtil.h"

@interface WSRequestDataCacheTable : WSSqliteUtil

+ (WSRequestDataCacheTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//插入数据
- (void)insertWithObject:(WSRequestDataCacheObject *)aObject;

//查询数据
- (NSArray *)queryWithObject:(WSRequestDataCacheObject *)aObject;


@end
