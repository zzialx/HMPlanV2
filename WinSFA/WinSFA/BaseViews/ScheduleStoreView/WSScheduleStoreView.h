//
//  WSScheduleStoreView.h
//  WinSFA
//
//  Created by zzialx on 2022/10/20.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPlanCalendarDataModel.h"

typedef void(^clickAttanceAction)(void);

NS_ASSUME_NONNULL_BEGIN

@interface WSScheduleStoreView : UIView

@property(nonatomic,copy)clickAttanceAction clickAttanceAction;
/// 考勤安排
@property(nonatomic,strong)WSAttenanceModel * attenanceModel;
/// 日程安排数据源
@property(nonatomic,strong)NSArray * schedduleTaskList;
/// 选中的日期
@property(nonatomic,copy)NSString * selectDate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setAttenanceRuleBlock:(clickAttanceAction)block;


@end

NS_ASSUME_NONNULL_END
