//
//  WSFuncTipDBService.h
//  WinSFA
//
//  Created by yang on 2017/8/30.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSFuncTipDBService : WSDBService

#pragma mark - 通过funcCode和empId查询提示标示方法
+ (NSString *)queryTipWithFuncCode:(NSString *)funcCode andEmpId:(NSString *)empId;

+ (void)updateTipWithFuncCode:(NSString *)funcCode andStoreId:(NSString *)storeId  count:(NSString*)count;

@end
