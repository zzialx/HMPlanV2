//
//  WSAcvtForGridController.h
//  WinSFA
//
//  Created by mac on 2017/10/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//
// 点击表格根据表格数据  转成调查问卷模型 绘制视图

#import "BaseViewController.h"
@class WSTableItem;
@class WSProdBean;

@interface WSAcvtForGridController : BaseViewController

@property (nonatomic,copy) void (^reloadGridView)(NSDictionary * dict,NSString * rowId);

- (id)initWithAcvtBean:(WSTableItem *)tableItem withItemId:(NSString *)itemId withItemName:(NSString *)itemName withDisplayValue:(NSDictionary *)dict withLuaScript:(NSString *)luaScript;

@end
