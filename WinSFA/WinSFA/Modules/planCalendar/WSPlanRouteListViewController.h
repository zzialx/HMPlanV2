//
//  WSPlanRouteListViewController.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
@class WSPlanRouteListDataModel;
@class WSPlanCalendarRouteDataInfoModel;
NS_ASSUME_NONNULL_BEGIN
@protocol WSPlanRouteListViewControllerDelegate <NSObject>

- (void)upLoadRouteCalendar;

@end
@interface WSPlanRouteListViewController : SuperWorkSpaceViewController
@property (nonatomic,strong) WSPlanCalendarRouteDataInfoModel *selectDataInfoModel;
@property (nonatomic,strong) WSPlanRouteListDataModel *routeListData;
@property (nonatomic, weak) id<WSPlanRouteListViewControllerDelegate> planRouteListViewCellDelegate;

@end

NS_ASSUME_NONNULL_END
