//
//  ProdBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "I_W_OptionDataItem.h"

@interface WSProdBean : NSObject <I_W_OptionDataItem>

// 产品品牌
@property (nonatomic, copy/*, readonly*/) NSString  *brand;
// 产品系列
@property (nonatomic, copy/*, readonly*/) NSString *series;
@property (nonatomic, copy/*, readonly*/) NSString  *cod;
@property (nonatomic, copy/*, readonly*/) NSString  *Id;
@property (nonatomic, copy/*, readonly*/) NSString  *name;
@property (nonatomic, copy/*, readonly*/) NSString  *pTyp;          // "1"为本品，"2"为竞品 ,etc;
@property (nonatomic, copy/*, readonly*/) NSString  *searchcod;
@property (nonatomic, copy/*, readonly*/) NSString  *url;
@property (nonatomic, copy/*, readonly*/) NSString  *brandType;
@property (nonatomic, copy/*, readonly*/) NSString  *barcod;
/*
 *  中粮稽核添加，用于校验时过滤产品，暂定 memo5 字段
 */
@property (nonatomic, copy/*, readonly*/) NSString  *memo5;
@property (nonatomic, copy/*, readonly*/) NSString  *prodName;
@property (nonatomic, copy/*, readonly*/) NSNumber  *price;


//中绿订单管理，产品品牌字段
@property (nonatomic, copy/*, readonly*/) NSString  *brandname;

// 同步安卓base_product添加memo字段
@property (nonatomic, copy/*, readonly*/) NSString *memo;

//新增字段(用于正则校验)
@property (nonatomic, copy/*, readonly*/) NSString *memo1;
@property (nonatomic, copy/*, readonly*/) NSString *memo2;
@property (nonatomic, copy/*, readonly*/) NSString *memo3;
@property (nonatomic, copy/*, readonly*/) NSString *memo4;
@property (nonatomic, copy/*, readonly*/) NSString *memo6;
@property (nonatomic, copy/*, readonly*/) NSString *memo7;
@property (nonatomic, copy/*, readonly*/) NSString *memo8;
@property (nonatomic, copy/*, readonly*/) NSString *memo9;
@property (nonatomic, copy/*, readonly*/) NSString *memo10;

// SFA-12254 新增产品从属不同系列的所有Id，产品组织架构
@property (nonatomic, copy/*, readonly*/) NSString *prodtrees;

//
@property (nonatomic, copy) NSString *pinyin;

// MN-45 保质期，天数，为与安卓一致设置为字符串
@property (nonatomic, copy) NSString *expirydate;

// MN-45 大龄
@property (nonatomic, copy) NSString *bigage;

// SFA-13289 产品图片类型
@property (nonatomic, copy) NSString *imgType;

@property (nonatomic, copy) NSString *barcode2;// 益海嘉里-传统渠道【订单管理】

//SFA-21967 扩充其它数据表联查出来的数值
@property (nonatomic, copy) NSString *dist;
@property (nonatomic, copy) NSString *pri;
@property (nonatomic, copy) NSString *inv;
@property (nonatomic, copy) NSString *disp;
@property (nonatomic, copy) NSString *sdisp;
@property (nonatomic, copy) NSString *cmpt;
@property (nonatomic, copy) NSString *oos;
@property (nonatomic, copy) NSString *mtd;
@property (nonatomic, copy) NSString *ord;
@property (nonatomic, copy) NSString *gofa;
@property (nonatomic, copy) NSString *aging;
@property (nonatomic, copy) NSString *otherdicts;
@property (nonatomic, copy) NSString *dt;
@property (nonatomic, copy) NSString *dn;
@property (nonatomic, copy) NSString *server_node;
@property (nonatomic, copy) NSString *item1;
@property (nonatomic, copy) NSString *item2;
@property (nonatomic, copy) NSString *item3;
@property (nonatomic, copy) NSString *item4;
@property (nonatomic, copy) NSString *item5;
@property (nonatomic, copy) NSString *item6;
@property (nonatomic, copy) NSString *item7;
@property (nonatomic, copy) NSString *item8;
@property (nonatomic, copy) NSString *item9;
@property (nonatomic, copy) NSString *item10;
@property (nonatomic, copy) NSString *item11;
@property (nonatomic, copy) NSString *item12;
@property (nonatomic, copy) NSString *item13;
@property (nonatomic, copy) NSString *item14;
@property (nonatomic, copy) NSString *item15;
@property (nonatomic, copy) NSString *item16;
@property (nonatomic, copy) NSString *item17;
@property (nonatomic, copy) NSString *item18;
@property (nonatomic, copy) NSString *item19;
@property (nonatomic, copy) NSString *item20;
@property (nonatomic, copy) NSString *item21;
@property (nonatomic, copy) NSString *item22;
@property (nonatomic, copy) NSString *item23;
@property (nonatomic, copy) NSString *item24;
@property (nonatomic, copy) NSString *item25;
@property (nonatomic, copy) NSString *item26;
@property (nonatomic, copy) NSString *item27;
@property (nonatomic, copy) NSString *item28;
@property (nonatomic, copy) NSString *item29;
@property (nonatomic, copy) NSString *item30;
@property (nonatomic, copy) NSString *item31;
@property (nonatomic, copy) NSString *item32;
@property (nonatomic, copy) NSString *item33;
@property (nonatomic, copy) NSString *item34;
@property (nonatomic, copy) NSString *item35;
@property (nonatomic, copy) NSString *item36;
@property (nonatomic, copy) NSString *item37;
@property (nonatomic, copy) NSString *item38;
@property (nonatomic, copy) NSString *item39;
@property (nonatomic, copy) NSString *item40;
@property (nonatomic, copy) NSString *item41;
@property (nonatomic, copy) NSString *item42;
@property (nonatomic, copy) NSString *item43;
@property (nonatomic, copy) NSString *item44;
@property (nonatomic, copy) NSString *item45;
@property (nonatomic, copy) NSString *item46;
@property (nonatomic, copy) NSString *item47;
@property (nonatomic, copy) NSString *item48;
@property (nonatomic, copy) NSString *item49;
@property (nonatomic, copy) NSString *item50;
@property (nonatomic, copy) NSString* cacheKeyId;

@property (nonatomic, copy) NSString *parentLevelName;
- (id)initWithObject:(id)object;

@end
