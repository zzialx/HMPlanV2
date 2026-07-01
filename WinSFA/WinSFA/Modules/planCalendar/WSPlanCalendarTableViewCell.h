//
//  WSPlanCalendarTableViewCell.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPlanCalendarDataModel.h"

NS_ASSUME_NONNULL_BEGIN
@class WSPlanCalendarRouteDataInfoModel;
@protocol WSPlanCalendarTableViewCell <NSObject>

- (void)btnDownViewCell:(WSPlanCalendarRouteDataInfoModel*)model;

@end
@interface WSPlanCalendarTableViewCell : UITableViewCell
@property(nonatomic,strong) WSPlanCalendarRouteDataInfoModel *model;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,assign) BOOL isBtn;
@property (nonatomic, weak) id<WSPlanCalendarTableViewCell> planCalendarViewCellDelegate;

/// 设置审核状态
/// - Parameter attanceModel: model
- (void)setAttanceStateWithApproveState:(NSString*)approveState;

@end

NS_ASSUME_NONNULL_END
