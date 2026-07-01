//
//  WSTskfRouteModel.h
//  WinSFA
//
//  Created by admin on 2022/10/29.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseModel.h"

@class WSTskfRouteStoreModel;

NS_ASSUME_NONNULL_BEGIN

@interface WSTskfRouteModel : WSBaseModel

@property(nonatomic,strong)NSArray <WSTskfRouteStoreModel *>* getMySpeRouteStore;

@end

@interface WSTskfRouteStoreModel : NSObject

/// 拜访日期
@property(nonatomic,copy)NSString * docDate;

/// 门店id
@property(nonatomic,copy)NSString * storeId;

/// 用户id
@property(nonatomic,copy)NSString * empId;

/// 排序
@property(nonatomic,copy)NSString * sort;

@end



NS_ASSUME_NONNULL_END
