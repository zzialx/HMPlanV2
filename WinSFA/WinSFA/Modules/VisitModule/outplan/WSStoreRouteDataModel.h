//
//  WSStoreRouteDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSStoreRouteDataInfoModel;
@class WSStoreDataInfoModel;
//==========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

@interface WSStoreRouteDataModel : NSObject

@property (nonatomic, strong) NSArray <WSStoreRouteDataInfoModel *>*routs;  //路线集合
@property (nonatomic, assign) NSInteger execNum;                            //已执行数量
@property (nonatomic, assign) NSInteger total;                              //路线总数
@property (nonatomic, assign) NSInteger unExecNum;                          //未计划路线数量
@property (nonatomic, assign) NSInteger limitTime;                          //时间戳
@property (nonatomic, copy) NSString *planRoute;                            //计划路线id
@property (nonatomic, copy) NSString *tipFlag;                              //提示标示
@property (nonatomic, copy) NSString *tip;                                  //提示语
@property (nonatomic, copy) NSString *curRoute;                             //当前路线id
@property (nonatomic, copy) NSString *prompt;                               //超过时间提示

@end
//==========================================================================================================================================

@interface WSStoreRouteDataInfoModel : NSObject

@property (nonatomic, copy) NSString *routeId;                          //路线id
@property (nonatomic, copy) NSString *effDate;                          //执行日期
@property (nonatomic, copy) NSString *effPlanDate;                      //执行日期
@property (nonatomic, copy) NSString *routeName;                        //路线名称
@property (nonatomic, copy) NSString *approveState;                     //申请状态
@property (nonatomic, copy) NSString *approveId;                        //申请id
@property (nonatomic, strong) NSArray <WSStoreDataInfoModel *>*stores;  //路线包含的门店及状态集合
@property (nonatomic, assign) NSInteger runExecNum;                     //未执行客户数
@property (nonatomic, assign) NSInteger rtotal;                         //客户总数
@property (nonatomic, assign) NSInteger estTime;                        //总在途时间/预计总在途时间 如果已执行客户数0（未计划）是预计总在途时间
@property (nonatomic, assign) NSInteger inTime;                         //总在店时间
@property (nonatomic, assign) NSInteger rexecNum;                       //已执行客户数
@property (nonatomic, assign) NSInteger isHidenDel;                     //是否隐藏删除按键
@property (nonatomic, assign) BOOL isToday;                             //是否是今日路线

@end
//==========================================================================================================================================

@interface WSStoreDataInfoModel : NSObject

@property (nonatomic, copy) NSString *storeId;  //id
@property (nonatomic, copy) NSString *state;    //状态
@property (nonatomic, assign) NSInteger sort;   //排序

@end

NS_ASSUME_NONNULL_END
//==========================================================================================================================================

