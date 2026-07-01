//
//  WSStoreBaseViewController.h
//  WinSFA
//
//  Created by yuanji on 2018/9/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"

#pragma mark - 门店视图管理器基地
@interface WSStoreBaseViewController : SuperWorkSpaceViewController

#pragma mark - 获取当前empid方法
- (NSString *)getCurrentEmpId;
//根据 func 和 门店 得到对应的  视图 应该抽出 不应该在公共视图里面
- (UIViewController *)nextPageWithFunsBean:(WSFuncsBean *)fb withINdexStore:(WSStoreBean *)store;

- (BOOL)gotoNextPageWithViewController:(UIViewController *)tmpVc withFuncsBean:(WSFuncsBean *)fb withStoreBean:(WSStoreBean *)store withAutoJump:(BOOL)isAuto;

@end
