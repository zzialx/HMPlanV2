//
//  WSSuggestHome.h
//  WinSFA
//
//  Created by huzepei on 16/9/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSSuggestHomePro : NSObject <NSCoding>

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

//每箱价格
@property (nonatomic,copy) NSString *priceBox;

//每菜用量
@property (nonatomic,copy) NSString *dosage;

//单位成本
@property (nonatomic,copy) NSString *homeCost;

//每菜成本
@property (nonatomic,copy) NSString *homeFoodCost;


//配方应用特需 ************************************

//配方用量
@property (nonatomic,copy) NSString *formulaDosage;

//配方成本
@property (nonatomic,copy) NSString *formulaCost;

//配方名称
@property (nonatomic,copy) NSString *peiName;

//人力成本
@property (nonatomic,copy) NSString *renliCost;

//原料成本
@property (nonatomic,copy) NSString *yuanliaoCost;

//制作成本
@property (nonatomic,copy) NSString *makeCost;

//每次制作量
@property (nonatomic,copy) NSString *makeEveryTime;

//是否为自制配方
@property (nonatomic,assign) BOOL isFormulaStyle;

//总成本
@property (nonatomic,strong) NSString *sumCost;

//配方成本
@property (nonatomic,strong) NSString *peiCost;

@end



@interface WSSuggestHomeModel : NSObject<NSCoding>

/**
 *  六个位置
 */
@property (nonatomic,strong) WSSuggestHomePro *ownSP_top;
@property (nonatomic,strong) WSSuggestHomePro *ownSP_mid;
@property (nonatomic,strong) WSSuggestHomePro *ownSP_bom;

@property (nonatomic,strong) WSSuggestHomePro *otherSP_top;
@property (nonatomic,strong) WSSuggestHomePro *otherSP_mid;
@property (nonatomic,strong) WSSuggestHomePro *otherSP_bom;

//区分配方应用还是菜单 -->  菜市应用和配方应用的homePro是不相同的.
@property (nonatomic,copy) NSString *sStype;

//本品   每菜成本
@property (nonatomic,copy) NSString *ownFoodCost;

//竞品   每菜成本
@property (nonatomic,copy) NSString *otherFoodCost;

// 点击率
@property (nonatomic,copy) NSString *clickRate;

//每月
@property (nonatomic,copy) NSString *monthMore;

//每年
@property (nonatomic,copy) NSString *yearMore;

//每月多创造利润
@property (nonatomic,copy) NSString * moreMonthFits;

@end


@interface WSSuggestHome : NSObject

@property (nonatomic,copy) NSString *ID;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) NSData *item;

@property (nonatomic,copy) NSString *dType;
@property (nonatomic,copy) NSString *empid;
@property (nonatomic,copy) NSString *biz_date;

//item转换之后的模型
@property (nonatomic,strong) WSSuggestHomeModel *sugHomeModel;

@end
