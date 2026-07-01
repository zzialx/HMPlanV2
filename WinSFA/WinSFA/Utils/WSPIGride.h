//
//  WSPIGride.h
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

/**
 *
 *
 *  PI类型 表格实现
 *
 *
 */
#import <Foundation/Foundation.h>
#import "WSTableItem.h"
#import "WSPITableView.h"

@interface WSPIGride : UIControl

/**
 *  是否显示表格
 */
@property (nonatomic , assign) BOOL isAlllowShow;

/**
 *  表格内容高度，根据要显示的表格行数计算。（目前不准，需要调试）
 */
@property (nonatomic , assign) CGFloat mContentHeight;

/**
 * 设置表格数据源
 *
 *  @param aVDictionary [WSTableItem.v objectFromJSONString]
 *  @param aSInfoType   storeInfo 类型 用于查找 表格的数
 *  @param aStoreId     门店ID 锁定门店数据
 */
- (void)setDataSurceWithDictionary:(WSTableItem *)tableItem andStoreInfoType:(NSString*)aSInfoType andStoreInfoId:(NSString*)aStoreId;

/**
 *  设置表格View显示区域。
 *
 *  @param frame
 */
- (void)showViewWithFrame:(CGRect)frame;

/**
 *  将UIScrollView类型父视图子视图，方便子视图显示高度超出父视图时，根据子视图的上下滑动的动作，来决定父视图是否上下移动
 *
 *  @param parent <#parent description#>
 */
- (void)setParent:(UIScrollView *) parent;
@end
