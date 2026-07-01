//
//  WSBaseInStoreProdTable.h
//  WinSFA
//
//  Created by heju on 16/8/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseInStoreProdTable : WSSqliteUtil

+ (instancetype)shareInstance;

- (BOOL)insertInStoreProdToDbWith:(NSArray *)inStroeProds serverNode:(NSString *)serverNode;

@end
