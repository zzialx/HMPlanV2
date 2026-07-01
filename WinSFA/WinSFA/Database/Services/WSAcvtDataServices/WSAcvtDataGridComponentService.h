//
//  WSAcvtDataGridComponentService.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-29.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtDataGridComponentView.h"

#import "WSTAAcvtDataGridViewPanel.h"

@class WSAcvtDataGridComponentDataSource;

@interface WSAcvtDataGridComponentService : NSObject

+ (BOOL)insertDataToTableWithWSAcvtDataGridComponentView:(WSAcvtDataGridComponentView *)aWSAcvtDataGridComponentView;

+ (BOOL)insertDataToTableWithWSAcvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)acvtDataGridViewDataSource;


/*
 因TA表格列为相关问卷的问题 数据源为为问题的opt选项
 TA类型的表格插入数据库（ws_add_newAct）
 */
+ (BOOL)insertTATableDataToDBWithTAPanel:(WSTAAcvtDataGridViewPanel *)taPanel;

/*更新TA表格上传成功的flag*/
+ (BOOL)updateTATableUploadFlagWith:(NSArray *)widgets acvtNewStoreId:(NSString *)newsid;

+ (NSDictionary *)getProdDictionaryWithDataSource:(WSAcvtDataGridComponentDataSource *)aWSAcvtDataGridComponentDataSource atIndex:(NSInteger)aIndex;
@end
