//
//  WSPlanFollowUpListViewController.h
//  WinSFA
//
//  Created by 董宏 on 2020/5/7.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
@class WSCalendarFollowUpDataModel;
@class WSPlanCalendarRouteManageDataInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface WSPlanFollowUpListViewController : SuperWorkSpaceViewController
@property (nonatomic,strong) WSCalendarFollowUpDataModel *followUpDataListModel;//下级model
@property (nonatomic,strong)  NSMutableArray  <WSPlanCalendarRouteManageDataInfoModel *>*followList;//现有随访集合
@property (nonatomic, copy)  NSString *leaderId;
@property (nonatomic, copy)  NSString *salesId;
@property (nonatomic, copy)  NSString *selecDate;

@end

NS_ASSUME_NONNULL_END
