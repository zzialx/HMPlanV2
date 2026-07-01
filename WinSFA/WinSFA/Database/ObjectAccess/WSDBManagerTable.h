//
//  WSDBManagerTable.h
//  WinSFA
//
//  Created by zhangke on 14/9/1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSDBManagerTable : WSSqliteUtil

+ (WSDBManagerTable *)sharedTable;

//创建所有表
- (BOOL)createAllDbTables;


//错误提示
- (int)updateErrorCode;

@end
