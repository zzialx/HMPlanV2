//
//  WSCallQstWidgetMethodBaseExecutor.h
//  WinSFA
//
//  Created by yang on 17/1/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSLuaExecutor.h"

@interface WSCallQstWidgetMethodBaseExecutor : WSLuaExecutor

- (NSString *)callWidget:(WSWidget *)widget method:(NSString *)methodName paramObj:(id)paramObj;

- (NSString *)batchCallWidgets:(NSArray *)widgetArray method:(NSString *)methodName paramObj:(id)paramObj;

@end
