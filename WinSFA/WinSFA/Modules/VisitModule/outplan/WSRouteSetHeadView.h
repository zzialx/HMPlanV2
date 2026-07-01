//
//  WSRouteSetHeadView.h
//  zhuanzhuan
//
//  Created by ZZUIHelper on 2022/10/24.
//  Copyright © 2017年 ZZUIHelper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreRouteDataModel.h"
//==========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WinRouteCellHeaderClickTypeRevoke,  //撤销
    WinRouteCellHeaderClickTypeDelete,  //删除
    WinRouteCellHeaderClickTypeEdit,    //编辑
    WinRouteCellHeaderClickTypeExecute  //执行
}
WinRouteCellHeaderClickType;            //单元格头部视图点击类型枚举

typedef void(^RouteHeadClickAction)(WinRouteCellHeaderClickType clickType); //定义点击闭包

#pragma mark - 路线设定头视图(单元格内头图)
@interface WSRouteSetHeadView : UIView

@property (nonatomic, copy) RouteHeadClickAction routeHeadClickAction; //点击闭包

- (void)setupTitleWithText:(NSString *)text model:(WSStoreRouteDataInfoModel *)model;//设置方法

@end

NS_ASSUME_NONNULL_END
//==========================================================================================================================================

