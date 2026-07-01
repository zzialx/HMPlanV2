//
//  WSSerieLinkView.h
//  WinSFA
//
//  Created by heju on 15/2/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//  可选择品牌及系列的视图（使用在产品表格或者调差问卷中）

#import <UIKit/UIKit.h>
#import "WSProdBeanArray.h"
#import "WSSerieLinkHeadView.h"

#import "WSProductTable.h"

@protocol WSSerieLinkViewDelegate;

@interface WSSerieLinkView : UIView <UITableViewDataSource,UITableViewDelegate> {
}

@property (nonatomic,strong) NSString *brandFilter;                             // 包含所有包含品牌（","分割）
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UITableView *brandTableView;
@property (nonatomic,strong) UITableView *serieTableView;
@property (nonatomic,assign) NSInteger selectedBrandIndex;                      //选择品牌列表的index
@property (nonatomic,assign) NSInteger selectedCategoryIndex;                   //选择系列列表的index
@property (nonatomic,assign) BOOL selectedBrandRow;                             // 是否选择过品牌cell
@property (nonatomic,assign) BOOL selectedSerieRow;                             // 是否选择过系列的cell
@property (nonatomic,assign) BOOL  contentViewHidden;
@property (nonatomic,assign) id<WSSerieLinkViewDelegate> delegate;
@property (nonatomic,strong) NSArray *m_selectedSerieProds;                     //所选择系列对应的产品
@property (nonatomic,strong) NSMutableArray *prodBrands;
@property (nonatomic,strong) NSMutableArray *showSeries;
@property (nonatomic,strong) __block NSMutableArray *prodBrandsNameAndId;
@property (nonatomic,strong) __block NSMutableArray *showSeriesName;
@property (nonatomic,strong) __block NSMutableDictionary *dataSourceDictionary; //存放以过滤的 品牌（id）/系列(id)/产品(id)的
@property (nonatomic,strong) NSMutableDictionary *addedProdBrandDictianry;      // 已填写产品所属品牌的字典
@property (nonatomic,strong) __block NSMutableArray *allBrandProds;             // 所有产品
@property (nonatomic,strong) NSMutableArray *allAddedProds;                     // 所有已填写的产品

- (id)initWithFrame:(CGRect)frame  brandFilter:(NSString *)brandFilter superProdGridMd5:(NSString *)md5;

// 重展现视图
- (void)redisplayWith:(NSMutableArray *)addedProds;
- (void)scrollToRowSelectIndexPath:(NSIndexPath *)indexPath;

@end

@protocol WSSerieLinkViewDelegate <NSObject>

- (void)willShowserieLinkView:(WSSerieLinkView *)serieLinkView didSelectRowAtBrandIndex:(NSInteger)brandIndex  andSerieIndex:(NSInteger)serieIndex  changedHeight:(CGFloat)changedHeight;

- (void)serieLinkView:(WSSerieLinkView *)serieLinkView didSelectRowAtBrandIndex:(NSInteger)brandIndex  andSerieIndex:(NSInteger)serieIndex selectedProds:(NSArray *)prods changedHeight:(CGFloat)changedHeight;



@end
