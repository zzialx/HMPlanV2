//
//  WSPlanRouteListDataModel.h
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class WSPlanRouteListDataInfoModel;

@interface WSPlanRouteListDataModel : NSObject
@property (nonatomic, copy)    NSArray <WSPlanRouteListDataInfoModel * >*getRouteInfo;//路线集合
@property (nonatomic, copy)    NSString *selectToday;//选中日期

@end

@interface WSPlanRouteListDataInfoModel : NSObject
@property (nonatomic, copy)  NSString *routeStatus;//状态
@property (nonatomic, copy)  NSString *routeName;//名称
@property (nonatomic, copy)  NSString *effDate;//日期
@property (nonatomic, assign)  NSInteger routeId;//路线id
@property (nonatomic, assign)  NSInteger empId;//
@end

NS_ASSUME_NONNULL_END
