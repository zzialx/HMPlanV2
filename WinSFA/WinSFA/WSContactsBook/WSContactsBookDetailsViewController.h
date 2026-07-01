//
//  WSContactsBookDetailsViewController.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "WSContactsBookServiceDataModel.h"

#pragma mark - 定义通讯录详情类型枚举
typedef NS_ENUM(NSInteger, WSContactsBookDetailsType)
{
    WSContactsBookDetailsTypePeople,//人的详情类型
    WSContactsBookDetailsTypeStore  //店的详情类型
};
//===================================================================================================================================================================

#pragma mark - 通讯录详情视图管理器
@interface WSContactsBookDetailsViewController : WCBaseViewController

@property (nonatomic, assign) WSContactsBookDetailsType detailsType;//详情类型
@property (nonatomic, strong) WSFuncsBean_opt *optData;             //opt数据
@property (nonatomic, strong) WSContactsStandardInfo *infoData;     //信息数据

@end
//===================================================================================================================================================================
