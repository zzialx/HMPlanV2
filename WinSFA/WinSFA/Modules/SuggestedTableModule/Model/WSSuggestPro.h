//
//  WSSuggestPro.h
//  WinSFA
//
//  Created by huzepei on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSuggestPro : NSObject

@property (nonatomic,copy) NSString *_id;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *cod;

@property (nonatomic,copy) NSString *pTyp;

@property (nonatomic,copy) NSString *brand;

@property (nonatomic,copy) NSString *price;

@property (nonatomic,copy) NSString *url;

@property (nonatomic,copy) NSString *memo1;

@property (nonatomic,copy) NSString *memo2;

@property (nonatomic,copy) NSString *memo3;

@property (nonatomic,copy) NSString *memo4;

//每箱利润
@property (nonatomic,copy) NSString *month_sales;

//每月销量
@property (nonatomic,copy) NSString *boxProfits;

@end
