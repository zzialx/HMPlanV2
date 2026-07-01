//
//  WSAttanceViewModel.h
//  WinSFA
//
//  Created by zzialx on 2022/10/19.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSBaseViewModel.h"
#import "WSPlanCalendarDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSAttanceViewModel : WSBaseViewModel

/// 获取考勤的审批状态以及备注
/// - Parameters:
///   - kqList: 列表数据
///   - dateStr: 时间
- (WSAttenanceModel*)getAttendanceStateListWithKqList:(NSArray*)kqList withDateStr:(NSString*)dateStr;


/// 获取某日路线计划数组
/// - Parameters:
///   - tableData: 列表数据
///   - dateStr: 日期
- (NSMutableArray*)getPlanRouteListWithTableData:(NSArray*)tableData withDateStr:(NSString*)dateStr;

/// 获取某日考勤数据
/// - Parameters:
///   - tableData: 列表数据
///   - dateStr: 日期
- (NSMutableArray*)getScheduleListWithTableData:(NSArray*)tableData withDateStr:(NSString*)dateStr;


/// 获取用户的日程安排
/// - Parameters:
///   - tableData:
///   - dateStr:
- (NSMutableArray*)getDayWorkPlanListWithPlanStoreList:(NSArray*)planStoreList withDateStr:(NSString*)dateStr;


/// 获取旧UI的审批状态
/// - Parameters:
///   - tableData:列表数据
///   - dateStr: 日期
- (NSString*)getOldRoleApproveStateWithTableData:(NSArray*)tableData withDateStr:(NSString*)dateStr;


/// 登录用户角色
+ (NSString*)getLoginUserRole;

@end

NS_ASSUME_NONNULL_END
