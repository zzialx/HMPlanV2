//
//  WSBaseEmployeTable.h
//  WinSFA
//
//  Created by weida on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseEmployeTable : WSSqliteUtil

+ (WSBaseEmployeTable *)sharedTable;

- (NSArray *)queryWithType:(NSString *)type;

@end
