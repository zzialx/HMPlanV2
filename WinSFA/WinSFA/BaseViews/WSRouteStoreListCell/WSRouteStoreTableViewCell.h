//
//  WSRouteStoreTbleViewCell.h
//  WinSFA
//
//  Created by zzialx on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreBean.h"
@class WSRouteStoreTableViewCell;
//==========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void(^showStoreAgreementAction)(WSStoreBean *cellStoreBean, BOOL isExpend, WSRouteStoreTableViewCell *cell);//定义显示门店协议闭包
typedef void(^jumpStoreInfoAction)(WSStoreBean *cellStoreBean, WSRouteStoreTableViewCell *cell);                    //定义跳转门店信息闭包

#pragma mark - 路线门店表视图单元格
@interface WSRouteStoreTableViewCell : UITableViewCell

@property (nonatomic, copy) showStoreAgreementAction showStoreAgreementAction;  //显示门店协议闭包
@property (nonatomic, copy) jumpStoreInfoAction jumpStoreInfoAction;            //跳转门店信息闭包

- (void)setStore:(WSStoreBean *)store withOpt:(WSFuncsBean_opt *)opt foldState:(NSString *)foldState; //设置门店数据方法

@end

NS_ASSUME_NONNULL_END
//==========================================================================================================================================
