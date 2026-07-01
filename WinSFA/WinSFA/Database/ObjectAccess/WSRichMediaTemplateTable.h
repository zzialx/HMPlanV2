//
//  WSRichMediaTemplateTable.h
//  WinSFA
//
//  Created by huzepei on 16/8/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"
#import "WSStoreBeans.h"
#import "WSRichItemModel.h"

@interface WSRichMediaTemplateTable : WSSqliteUtil

+ (WSRichMediaTemplateTable *)sharedTable;

- (BOOL)insertTableWithStore:(WSStoreBean *)storeBean dict:(NSDictionary *)dict visitData:(NSString *)visitData;

/**
 *  查询模板-模板是全局的
 */
- (NSArray *)queryTableForTemplate;

/**
 *  根据门店名称或ID获取演示列表
 */
- (NSArray *)queryTableFordemoList:(NSString *)storeID;

/**
 *  获取所有的门店的演示列表
 */
- (NSArray *)queryTabledemoList;

/**
 *  插入单独的富媒体数据,跟店绑定,与模板没有关系
 */

- (BOOL)insertDemoListTabWithStore:(WSStoreBean *)storeBean richMedia:(WSRichItemModel *)richItem visitData:(NSString *)visitData;
/**
 *  删除
 */
-(BOOL)deleteRichListWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values;

/**
 *  查询--demolisT定制
 */
- (NSArray *)queryTableForRichItem:(NSString *)storeID;

/**
 *  获取所有演示列表不关联门店
 */
-(NSArray *)queryTabledemoListNotHavePid;

/**
 *  获取当前门店时间的演示列表
 */
- (NSArray *)queryTableFordemoList:(NSString *)storeID andVisitTime:(NSString *)visitTime;
/**
 *  获取当前门店时间的演示列表的富媒体
 */
- (NSArray *)queryTableForRichItem:(NSString *)storeID andVisitTime:(NSString *)visitTime;
@end
