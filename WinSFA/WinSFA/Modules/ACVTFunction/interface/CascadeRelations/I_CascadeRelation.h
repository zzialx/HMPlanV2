//
//  I_CascadeRelation.h
//  WinSFA
//
//  Created by yang on 16/12/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_BuildInfo.h"

@protocol I_CascadeRelation <NSObject>

@property (nonatomic, weak) id<I_CascadeRelation> parentWidget;

//@property (nonatomic, weak) id<I_CascadeRelation> subWidget;

- (NSString *)getQstID;

- (NSString *)getParentQstID;

- (NSString *)getSelectedItemID;

/**
 * @brief 从链表头开始初始化回显数据及数据源。（初始化时调用）
 */
- (void)initDataForCascadeRelation:(BOOL)isRefreshSelf;

/**
 * @brief 清空选择，刷新数据源 （父控件选项改变时调用）
 */
- (void)cleanSelectionAndRefreshDataSource;

@optional

//for multiple select
- (NSArray *)getSelectedItemArray;

#pragma -mark MN-1633
-(void)addSubWidgetObject:(id<I_CascadeRelation>)object;
-(NSArray *)getAllSubWidget;

@end
