//
//  WSBaseProductTable.h
//  WinSFA
//
//  Created by weida on 15/12/25.
//  Copyright © 2015年 WinChannel. All rights reserved.
//
#import "WSSqliteUtil.h"


@interface WSBaseProductTable : WSSqliteUtil

+ (WSBaseProductTable *)sharedTable;

@end
