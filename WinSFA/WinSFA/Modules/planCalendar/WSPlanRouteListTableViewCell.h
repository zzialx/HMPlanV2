//
//  WSPlanRouteListTableViewCell.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class WSPlanRouteListDataInfoModel;

@interface WSPlanRouteListTableViewCell : UITableViewCell
@property(nonatomic,strong) WSPlanRouteListDataInfoModel *model;
@property (nonatomic, strong) UIImageView *setImg;

@end

NS_ASSUME_NONNULL_END
