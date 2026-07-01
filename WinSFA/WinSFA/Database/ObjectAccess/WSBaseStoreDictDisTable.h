//
//  WSBaseStoreDictDisTable.h
//  WinSFA
//
//  Created by heju on 16/3/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreDictDisTable : WSSqliteUtil

+ (WSBaseStoreDictDisTable *)sharedTable;


- (void)insertDictdisDatasWith:(NSArray *)dictdiss;

@end
