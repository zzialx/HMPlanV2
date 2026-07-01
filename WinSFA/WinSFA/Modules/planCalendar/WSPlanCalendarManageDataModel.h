//
//  WSPlanCalendarManageDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/29.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class WSPlanCalendarManageDataInfoModel;
@class WSPlanCalendarRouteManageDataInfoModel;

@interface WSPlanCalendarManageDataModel : NSObject
@property (nonatomic, copy)    NSArray <WSPlanCalendarManageDataInfoModel * >*tableData;//路线集合
@property (nonatomic, assign)  NSInteger empId;//人员id
@property (nonatomic, copy)    NSString *empType; //人员类型
@property (nonatomic, copy)  NSString *approveFlag;//主管提示语
@end

@interface WSPlanCalendarManageDataInfoModel : NSObject
@property (nonatomic, copy)  NSString *day;//日期
@property (nonatomic, copy)  NSArray  <WSPlanCalendarRouteManageDataInfoModel *>*salesList;//业代列表
@property (nonatomic, copy)  NSArray  <WSPlanCalendarRouteManageDataInfoModel *>*leaderList;//主管列表
@property (nonatomic, copy)  NSString *forenoon;//上午
@property (nonatomic, copy)  NSString *afternoon;//下午
@property (nonatomic, copy)  NSString *allday;//全天
///上午备注
@property (nonatomic, copy)  NSString *forenoonMemo;
/// 下午备注
@property (nonatomic, copy)  NSString *afternoonMemo;

@end

@interface WSPlanCalendarRouteManageDataInfoModel : NSObject
@property (nonatomic, copy)  NSString *leaderId;//主管id
@property (nonatomic, copy)  NSString *leaderName;//主管名字
@property (nonatomic, copy)  NSString *salesId;//业代id
@property (nonatomic, copy)  NSString *salesName;//业代名字
@property (nonatomic, copy)  NSString *storeId;//门店id
@property (nonatomic, copy)  NSString *storeName;//门店名字
@property (nonatomic, copy)  NSString *dataId;//数据id
@property (nonatomic, copy)  NSString *flag;//状态


@end
NS_ASSUME_NONNULL_END
