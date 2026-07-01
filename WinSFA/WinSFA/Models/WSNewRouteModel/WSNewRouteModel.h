//
//  WSNewRouteModel.h
//  WinSFA
//
//  Created by admin on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseModel.h"

@class WSNewRouteModel;

NS_ASSUME_NONNULL_BEGIN

@interface WSNewRouteListModel : WSBaseModel

/// 路线列表
@property(nonatomic,strong)NSArray<WSNewRouteModel*> * getMySpeRouteInfo;


@end

@interface WSNewRouteModel : NSObject

/// 拜访日期
@property(nonatomic,copy)NSString * docDate;

/// 门店总数
@property(nonatomic,copy)NSString * storeNum;

/// 拜访率
@property(nonatomic,copy)NSString * bfRate;

/// 执行状态
@property(nonatomic,copy)NSString * zxState;

/// 审批状态
@property(nonatomic,copy)NSString * approveState;


@end

NS_ASSUME_NONNULL_END
