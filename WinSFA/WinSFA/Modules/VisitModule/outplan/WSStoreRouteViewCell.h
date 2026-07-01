//
//  WSStoreRouteViewCell.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSStoreRouteDataInfoModel;
//==========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void(^CurrentRouteRevokeActionBlock)(NSString *routeId);    //定义撤销闭包
typedef void(^CurrentRouteDelegateActionBlock)(NSString *routeId);  //定义删除闭包
typedef void(^CurrentRouteEditActionBlock)(NSString *routeId);      //定义编辑闭包
typedef void(^CurrentRouteExecuteActionBlock)(NSString *routeId);   //定义执行闭包

#pragma mark - 门店路线单元格
@interface WSStoreRouteViewCell : UITableViewCell

@property (nonatomic, copy) CurrentRouteRevokeActionBlock revokeActionBlock;    //撤销闭包
@property (nonatomic, copy) CurrentRouteDelegateActionBlock delegateActionBlock;//删除闭包
@property (nonatomic, copy) CurrentRouteEditActionBlock editActionBlock;        //编辑闭包
@property (nonatomic, copy) CurrentRouteExecuteActionBlock executeActionBlock;  //执行闭包

- (void)setupInfoWithModel:(WSStoreRouteDataInfoModel *)model routeId:(NSString *)routeId isLast:(BOOL)isLast; //设置信息方法

@end

NS_ASSUME_NONNULL_END
//==========================================================================================================================================

