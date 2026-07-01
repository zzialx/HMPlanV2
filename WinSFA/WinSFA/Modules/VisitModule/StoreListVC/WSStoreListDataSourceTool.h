//
//  WSStoreListDataSourceTool.h
//  WinSFA
//
//  Created by sunhf on 2018/1/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseStoreDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSRequestHelper.h"
@interface WSStoreListDataSourceTool : NSObject

#pragma mark - 数据库获得今日拜访列表数据
+ (NSMutableArray *)initStoreListDataSourceWithFuncBean:(WSFuncsBean *)currentFuncs withSubempstoreBean:(WSSubempstoreBean *)subempStore;

#pragma mark - 对门店按照规则要求排序 - 辉瑞医院 SFA-16255
/*
 排序方式：从上到下
 从A级别医院到D级别医院
 从当月拜访次数为0的医院到当月拜访次数多次
 */
+ (NSMutableArray *)sortStoreWithDataArray:(NSMutableArray *)storeDataArray;

/*
 获得今日拜访列表里计划内门店的个数
 */
+ (NSInteger)getInPlanNumber;

#pragma mark - 计划内门店网络请求
+ (void)requestInPlanWithStoreBean:(WSStoreBean*)store successCallBack:(void(^)(id))successCallback failCallback:(void(^)(NSString *error))failCallback;

#pragma mark - 计划外门店网络请求
+ (void)requestOutPlanWithStoreBean:(WSStoreBean*)store successCallBack:(void(^)(id))successCallback failCallback:(void(^)(NSString *error))failCallback;
@end
