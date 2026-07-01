//
//  WSSuggestWholesale.h
//  WinSFA
//
//  Created by huzepei on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSuggestPro : NSObject <NSCoding>

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



@interface WSSuggestWhoModel : NSObject<NSCoding>

/**
 *  四个位置
 */
@property (nonatomic,strong) WSSuggestPro *ownSP_wholesale;
@property (nonatomic,strong) WSSuggestPro *ownSp_terminal;
@property (nonatomic,strong) WSSuggestPro *otherSP_wholesale;
@property (nonatomic,strong) WSSuggestPro *otherSp_terminal;

//每月利润 (本品)
@property (nonatomic,copy) NSString * proFits;
//每月利润 (竞品)
@property (nonatomic,copy) NSString * compFits;
//每月多创造利润
@property (nonatomic,copy) NSString * moreMonthFits;
//每年多创造利润
@property (nonatomic,copy) NSString * moreYearFits;

@end



@interface WSSuggestWholesale : NSObject

@property (nonatomic,copy) NSString *ID;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) NSData *item;

@property (nonatomic,copy) NSString *dType;
@property (nonatomic,copy) NSString *empid;
@property (nonatomic,copy) NSString *biz_date;

//item转换之后的模型
@property (nonatomic,strong) WSSuggestWhoModel *sugModel;

@end
