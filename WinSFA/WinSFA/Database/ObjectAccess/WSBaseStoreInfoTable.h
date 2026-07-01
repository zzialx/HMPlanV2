//
//  WSBaseStoreInfoTable.h
//  WinSFA
//
//  Created by HZH on 2017/11/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreInfoTable : WSSqliteUtil

+ (WSBaseStoreInfoTable *)sharedTable;

@end
