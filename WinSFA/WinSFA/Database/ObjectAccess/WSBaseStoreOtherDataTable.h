//
//  WSBaseStoreOtherDataTable.h
//  WinSFA
//
//  Created by heju on 15/12/8.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"
 
#import "WSMappingObject.h"

@interface WSBaseStoreOtherDataTable : WSSqliteUtil

+ (WSBaseStoreOtherDataTable *)sharedTable;
/**
 *  清楚过期临时数据
 */
- (void)cleanOldData;

- (void)insertItem1Value:(NSString *)value1 Item2value:(NSString *)value2;

- (NSArray *)queryBaseStoreOtherDataObject:(NSString *)item1Value;
- (void)cleanOldDataAboutCityStoreListCount;//YIHAIKERRY-3780  SFA 益海嘉里【门店下载中心】切换账号后，门店下载中心的下载记录没有被清除

/**
 *  @author weida
 *
 *  @brief 从base_store_other_data数据库中找到对于key的值（如果有多条记录满足条件，则返回第一条记录的值）
 *
 *  @param key  对应表中字段item1
 *  @param type 对应表中字段type
 *
 *  @return 返回记录的item2字段的值
 */
-(id)valueForKey:(NSString *)key type:(NSString*)type;

@end
