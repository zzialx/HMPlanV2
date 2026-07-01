//
//  WSInventoryModel.h
//  WinSFA
//
//  Created by zzialx on 2025/7/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSInventoryModel : NSObject

@property (nonatomic, copy) NSString * storeCode;
@property (nonatomic, copy) NSString * prodName;
@property (nonatomic, copy) NSString * count;
//购进数量
@property (nonatomic, copy) NSString * gjsl;
//建议数量
@property (nonatomic, copy) NSString * jysl;
//字体颜色
@property (nonatomic, copy) NSString * color;

@end

@interface WSStockOutModel : NSObject

@property (nonatomic, copy) NSString * qhDays;

@property (nonatomic, copy) NSString * prodName;

@end

@interface WSInventoryResultModel : NSObject

@property (nonatomic, strong) NSArray <WSInventoryModel*> * data;

@property (nonatomic, copy) NSString * sum;

@property (nonatomic, copy) NSString * url;

@property (nonatomic, copy) NSString * mobileFileName;

//购进数量
@property (nonatomic, copy) NSString * gjSum;
//建议数量
@property (nonatomic, copy) NSString * jySum;

@property (nonatomic, copy) NSString * invProposeRemind;

//缺货数据源
@property (nonatomic, strong) NSArray <WSStockOutModel*> * otoData;


@end








NS_ASSUME_NONNULL_END
