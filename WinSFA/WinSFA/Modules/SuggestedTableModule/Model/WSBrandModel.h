//
//  WSBrandModel.h
//  WinSFA
//
//  Created by huzepei on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//  品牌模型 区分本品和竞品

#import <Foundation/Foundation.h>

@interface WSBrandModel : NSObject

// 品牌ID,产品表的过滤条件
@property (nonatomic,copy) NSString *_id;

@property (nonatomic,copy) NSString *name;

// prodBrand   代表着品牌
@property (nonatomic,copy) NSString *typ;

// prod 本品,  comp 竞品
@property (nonatomic,copy) NSString *dtyp;

@end
