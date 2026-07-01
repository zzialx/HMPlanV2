//
//  WSAddProductQstTable.h
//  WinSFA
//
//  Created by zhangke on 14/9/14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSAddProductQstTable : WSSqliteUtil

+ (WSAddProductQstTable*)sharedTable;

- (NSArray*)queryQstByAnsId:(NSString*)aAnsId andQstId:(NSString*)aQstId;

@end
