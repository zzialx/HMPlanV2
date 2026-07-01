//
//  WSRichMediaTable.h
//  WinSFA
//
//  Created by huzepei on 16/8/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSRichMediaTable : WSSqliteUtil

+ (WSRichMediaTable *)sharedTable;

// 查找所有的富媒体模型对象.
-(NSArray *)queryTableItems;

//未下载的img数量
-(NSArray *)queryTableItemsNotDownloadWithImg;

//未下载的h5数量
-(NSArray *)queryTableItemsNotDownloadWithH5;

//有效的H5URL地址
-(NSArray *)queryTableItemsNotDownloadWithH5URL;

// 根据ID更新表中的文件存储的路径  h5路径和img路径
-(BOOL)updateTableWithKey:(NSString *)key value:(NSString *)value ID:(NSString *)ID;

-(NSString *)getUpdateSQLStringWithKey:(NSString *)key value:(NSString *)value ID:(NSString *)ID;

// 插入数据
-(BOOL)insertWithValue:(NSArray *)values;


// 批量更新数据
- (BOOL)updateTableWithValueArr:(NSArray *)valueArr ID:(NSArray *)IDArray;


@end
