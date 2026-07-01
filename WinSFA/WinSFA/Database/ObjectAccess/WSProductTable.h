//
//  WSProductTable.h
//  WinSFA
//
//  Created by zhangke on 14/9/17.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSProductTable : WSSqliteUtil

+(WSProductTable*)sharedTable;

- (void)deleteProductWithGenId:(NSString *)genId prodIds:(NSArray *)prodIds;

@end
