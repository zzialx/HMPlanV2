//
//  WSPopUpProductViewController.h
//  WinSFA
//
//  Created by huzepei on 16/7/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSSuggestPro;
@class WSSuggestWhoModel;
@class WSCateModel;

@interface WSPopUpProductViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *dataArr;

/**
 *  WSSuggestPro = sp
 */
@property(nonatomic,copy) void (^sp)(WSSuggestPro *,WSCateModel *currentCate);

/**
 *  是否显示title
 */
@property (nonatomic,assign,getter = isShowProdTitle) BOOL showProdTitle;

/**
 *  本品还是竞品 proType = 0 本品  = 1 竞品
 */
@property (nonatomic,assign) int proType;

@property (nonatomic,strong) WSSuggestPro * sww;

//当前的品类的model,说明已有值,直接显示,并且不可修改.
@property (nonatomic, strong) WSCateModel *curOutCateModel;

@property(nonatomic,copy) void (^currentCate)(WSCateModel *);

@end
