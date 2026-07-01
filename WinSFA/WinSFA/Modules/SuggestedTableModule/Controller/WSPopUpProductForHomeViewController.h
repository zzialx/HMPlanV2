//
//  WSPopUpProductForHomeViewController.h
//  WinSFA
//
//  Created by HZH on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSuggestWholesale.h"
@class WSSuggestHomePro;
@class WSCateModel;

@interface WSPopUpProductForHomeViewController : UIViewController
/**
 *  WSSuggestProduct = sp
 */
@property(nonatomic,copy) void (^sp)(WSSuggestHomePro * , WSCateModel *);

@property(nonatomic,copy) void (^currentCate)(WSCateModel *);

// 模板类型 [01:菜式应用  02:配方应用]
@property (nonatomic, copy) NSString *sStyle;

// 产品类型 [01:联合利华策划产品  02:非联合利华策划产品]
@property (nonatomic, copy) NSString *productOwnerType;

@property (nonatomic, strong) WSSuggestHomePro *shp;

//当前的品类的model,说明已有值,直接显示,并且不可修改.
@property (nonatomic, strong) WSCateModel *curOutCateModel;

@end
