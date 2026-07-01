//
//  WSStoreRouteViewHeaderView.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSStoreRouteDataModel;
//==========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WinStoreRouteHeaderClickTypeSearch, //搜索
    WinStoreRouteHeaderClickTypeAdd,    //新增
    WinStoreRouteHeaderClickTypeModify  //修改
}
WinStoreRouteHeaderClickType;           //头部视图点击类型枚举

typedef void(^StoreRouteHeaderClick)(WinStoreRouteHeaderClickType clickType); //定义点击闭包

@interface WSStoreRouteViewHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) StoreRouteHeaderClick storeRouteHeaderClick;//点击闭包

- (void)setInfoWithData:(WSStoreRouteDataModel *)dataModel;//设置信息方法

@end

NS_ASSUME_NONNULL_END
//==========================================================================================================================================

