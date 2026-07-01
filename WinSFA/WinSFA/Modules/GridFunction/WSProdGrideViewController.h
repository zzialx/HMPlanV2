//
//  ProdGrideViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSBaseGrideViewController.h"

@interface WSProdGrideViewController : WSBaseGrideViewController
{}
@property (nonatomic, strong) NSMutableArray    *m_store_prod;
// 此属性已经移动至父类
//@property (nonatomic, strong) NSString *iBrandId; // brand id for filter product from the prods element
@property (nonatomic, strong) UIButton *moreProductButton;
@property (nonatomic, strong) UIButton *rqProductButton;
@property (nonatomic ,strong) UIButton *editProdctButton;

@property (nonatomic ,strong) NSMutableArray *buttonArray;


- (NSArray *)getProductsWithBrand:(NSString *)aBrand;

/**
 *  将filter的值转换成数组形式。（非品牌配置模式）
 *
 *  @return NSArray
 */
- (NSArray *) getProdTypeArray;
@end
