//
//  WSSuggestListTable.h
//  WinSFA
//
//  Created by huzepei on 16/9/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSuggestWholesale.h"
#import "WSSuggestHome.h"
@interface WSSuggestListTable : WSSqliteUtil

+ (WSSuggestListTable *)sharedTable;

// 批发产品插入数据库(模板)
- (BOOL)insertTableWithType:(NSString *)type  model:(WSSuggestWholesale *)suggestWho sid:(NSString *)sid withbiz_date:(NSString *)biz_date;

// 用家产品插入(sid:null模板  sid有值是本地回)
- (BOOL)insertTableWithType:(NSString *)type  homeModel:(WSSuggestHome *)suggesthome sid:(NSString *)sid withbiz_date:(NSString *)biz_date;


- (NSArray *)queryWithType:(NSString *)type  name:(NSString *)name sid:(NSString *)sid withbiz_date:(NSString *)biz_date className:(NSString *)className;

// 根据type查询出所有的模板
- (NSArray *)queryTableForSuggestListType:(NSString *)type className:(NSString *)className;

// 根据门店ID查询本地需要回显的数据
- (NSArray *)queryTableForSuggestListType:(NSString *)type sid:(NSString *)sid className:(NSString *)className withbiz_date:(NSString *)biz_date;

// 删除
- (BOOL)deleteSuggestWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values;





@end
