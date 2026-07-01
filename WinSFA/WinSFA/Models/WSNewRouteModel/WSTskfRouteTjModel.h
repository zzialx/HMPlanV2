//
//  WSTskfRouteTjModel.h
//  WinSFA
//
//  Created by admin on 2022/12/6.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseModel.h"

@class WSTskfRouteTjInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface WSTskfRouteTJModel : WSBaseModel

@property(nonatomic,strong)NSArray <WSTskfRouteTjInfoModel *>* getMySpeRouteTotal;

@end

@interface WSTskfRouteTjInfoModel : NSObject

/// 路线总数
@property(nonatomic,copy)NSString * totalNo;

/// 执行数量
@property(nonatomic,copy)NSString * zxNo;


@end

NS_ASSUME_NONNULL_END
