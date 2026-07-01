//
//  WSBaseStoreDistrule.h
//  WinSFA
//
//  Created by yang on 17/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreDistruleTable : WSSqliteUtil

+ (WSBaseStoreDistruleTable *)sharedTable;

@end
