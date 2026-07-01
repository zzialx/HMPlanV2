//
//  WSGridLinkPopupView.h
//  WinSFA
//
//  Created by heju on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//
/**
 点击WSSerieLinkHeadView，弹出的加载在window的视图（为WSGridLinkView的一部分）
 左侧列表加载品牌名称，右侧列表加载系列名称，点击左侧刷新右侧品牌对应的系列
 */

#import <UIKit/UIKit.h>
#import "WSProductTable.h"

typedef enum {
    WSAllType,
    WSBrandType
}WSBrandSerieType;


@protocol WSGridLinkPopupViewDelegate;

@interface WSGridLinkPopupView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *brandTableView;
@property (nonatomic, strong) UITableView *serieTableView;
@property (nonatomic, assign) WSBrandSerieType brandSerieType;
@property (nonatomic, strong) __block NSMutableArray *brands;
@property (nonatomic, strong) NSMutableArray *series;
@property (nonatomic, strong) NSString *brandIdsString;
@property (nonatomic, strong) NSMutableArray *allBrandProds;
@property (nonatomic, strong) NSMutableDictionary *trimmingDataSource;
@property (nonatomic, assign) NSInteger selectedBrandIndex;
@property (nonatomic, assign) NSInteger selectedSerieIndex;
@property (nonatomic,assign) BOOL selectedBrandRow;                             // 是否选择过品牌cell
@property (nonatomic,assign) BOOL selectedSerieRow;                             // 是否选择过系列的cell
@property (nonatomic, strong) NSMutableArray *allEditedProds;
@property (nonatomic, strong) NSMutableDictionary *editedBrandProdsDictionary;
@property (nonatomic, strong) NSMutableDictionary *editedSerieProdsDicionary;
@property (nonatomic, weak) id<WSGridLinkPopupViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *uploadedEditedProds;

- (id)initWithFrame:(CGRect)frame   brandFilter:(NSString *)brandFilter  md5:(NSString *)superGridMd5 prods:(NSArray *)prods appendprop:(NSString *)appendprop;
- (id)initWithFrame:(CGRect)frame brandFilter:(NSString *)brandFilter md5:(NSString *)superGridMd5 prods:(NSArray *)prods params:(NSArray *)params appendprop:(NSString *)appendprop;
/*
 storeId :若storeBean的drId存在取drId,否则取storeBean的storeId
 */

- (id)initWithFrame:(CGRect)frame  storeId:(NSString *)storeId params:(NSArray *)params brandFilter:(NSString *)brandFilter md5:(NSString *)superGridMd5 brandSerieType:(WSBrandSerieType)brandSerieType prods:(NSArray *)serverRedisProds appendprop:(NSString *)appendprop;

- (void)redisplayWith:(NSArray *)editedProds;
- (void)scrollToRowSelectIndexPath:(NSIndexPath *)indexPath;

@end

@protocol WSGridLinkPopupViewDelegate <NSObject>

- (void)gridLinkPopupView:(WSGridLinkPopupView *)popupView didSelecteBrandRowAtIndex:(NSInteger)brandIndex  serieIndex:(NSInteger)serieIndex prods:(NSArray *)prods andBrandSerieName:(NSString *)brandSerieName;
- (void)gridLinkPopupView:(WSGridLinkPopupView *)popupView  didSelectedAllEditedProds:(BOOL)show andBrandSerieName:(NSString *)brandSerieName;
@end
