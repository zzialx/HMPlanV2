//
//  WSStoreOtherBean.h
//  WinSFA
//
//  Created by winchannel on 2017/10/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSStoreOtherBean : NSObject<NSCopying,I_W_OptionDataItem>

@property (nonatomic, strong) NSString *emp_id;
@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) NSString *biz_date;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *item1;
@property (nonatomic, strong) NSString *item2;
@property (nonatomic, strong) NSString *item3;
@property (nonatomic, strong) NSString *item4;
@property (nonatomic, strong) NSString *item5;
@property (nonatomic, strong) NSString *item6;
@property (nonatomic, strong) NSString *item7;
@property (nonatomic, strong) NSString *item8;
@property (nonatomic, strong) NSString *item9;
@property (nonatomic, strong) NSString *item10;
@property (nonatomic, strong) NSString *item11;
@property (nonatomic, strong) NSString *item12;
@property (nonatomic, strong) NSString *item13;
@property (nonatomic, strong) NSString *item14;
@property (nonatomic, strong) NSString *item15;
@property (nonatomic, strong) NSString *item16;
@property (nonatomic, strong) NSString *item17;
@property (nonatomic, strong) NSString *item18;
@property (nonatomic, strong) NSString *item19;
@property (nonatomic, strong) NSString *item20;

@property (nonatomic, assign) NSInteger queryCount; // 查询结果总数，用于 sql 查询总数

@end
