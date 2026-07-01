//
//  WSPlanCalendarDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class WSPlanCalendarDataInfoModel;
@class WSPlanCalendarRouteDataInfoModel;
@class WSPlanStoreModel;
@class WSAttenanceModel;

@interface WSPlanCalendarDataModel : NSObject
@property (nonatomic, copy)    NSArray <WSPlanCalendarDataInfoModel * >*tableData;//路线集合

/**
 考勤安排
 */
@property (nonatomic, copy)    NSArray <WSAttenanceModel* >*kqInfo;

/**
 日程安排
 */
@property (nonatomic, copy)    NSArray <WSPlanStoreModel * >*callPlanStoreList;


@property (nonatomic, assign)  NSInteger empId;//人员id

@property (nonatomic, copy)    NSString *empType; //人员类型

/**
 提示语
 */
@property (nonatomic, copy)    NSString *rcTx;


@end

@interface WSPlanCalendarDataInfoModel : NSObject
@property (nonatomic, copy)  NSString *day;//日期
@property (nonatomic, copy)  NSArray  <WSPlanCalendarRouteDataInfoModel *>*visitList;//路线列表
@property (nonatomic, copy)  NSString *forenoon;//上午
@property (nonatomic, copy)  NSString *afternoon;//下午
@property (nonatomic, copy)  NSString *allday;//全天
/**
 上午备注
 */
@property (nonatomic, copy)  NSString *forenoonMemo;

/**
 下午备注
 */
@property (nonatomic, copy)  NSString *afternoonMemo;

/**
 审批状态
 */

@property (nonatomic, copy)  NSString *approveName;

@end

@interface WSPlanCalendarRouteDataInfoModel : NSObject

@property (nonatomic, copy)  NSString *routeId;//路线id

@property (nonatomic, copy)  NSString *routeName;//路线名称


@end

@interface WSAttenanceModel : NSObject

/**
 审批状态
 */
@property(nonatomic, copy)  NSString * approveName;

/**
 上午考勤备注
 */
@property(nonatomic, copy)  NSString * forenoonMemo;

/**
 下午考勤备注
 */
@property(nonatomic, copy)  NSString * afternoonMemo;
/**
 全天考勤备注
 */
@property(nonatomic, copy)  NSString * allDayaMemo;

/**
 上午考勤安排
 */
@property(nonatomic, copy)  NSString * forenoon;

/**
 下午考勤安排
 */
@property(nonatomic, copy)  NSString * afternoon;

/**
 日期
 */
@property(nonatomic, copy)  NSString * day;


@end


@interface WSPlanStoreModel : NSObject

/**
 日程安排商店名字
 */
@property(nonatomic, copy)  NSString * storeName;
/**
 日程安排商店code
 */
@property(nonatomic, copy)  NSString * storeCode;
/**
 日程安排商店等级
 */
@property(nonatomic, copy)  NSString * storeLevel;
/**
 日期
 */
@property(nonatomic, copy)  NSString * day;

@end


NS_ASSUME_NONNULL_END
