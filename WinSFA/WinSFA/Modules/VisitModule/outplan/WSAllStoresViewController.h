//
//  WSAllStoresViewController.h
//  WinSFA
//
//  ******是用来替换WSOutPlanViewController的。
//
//  Created by xiajl on 14-8-18.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreListBaseViewController.h"
#import "WSFuncsBean.h"
#import "WSSelectListTableViewCell.h"

#import "WSAllStoresMapViewController.h"
#import "FileManager.h"
#import "WSSearchBar.h"
#import "MJRefreshAutoNormalFooter.h"
#import "WSAllStoreSectionView.h"
#import "WSStoreHttpService.h"


#define  kHelpSalesName       @"助销"

#define  kVisitName           @"拜访"

#define UPDATA_NOTIFY       @"outPlan_notify"

#define ALL_STORE_FILTER_FLAG @"allstore"
#define kIsSearchAbleAuto         @"auto"
#define kIsSearchAbleRemote         @"remote"
typedef NS_ENUM(NSUInteger, WSAllStoresCategory)
{
    WSAllStoresCategoryNormal,        //门店清单（计划内+计划外）
    WSAllStoresCategoryOutPlan        //计划外
};


//TODO:对上层依赖，需要重构
//#import "SP_AddNewStoreViewController.h"
@class WSStoreBean;

@interface WSAllStoresViewController : WSStoreListBaseViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,WSSelectListTableViewCellDelegate>


@property (nonatomic, strong) WSSearchBar       *ownSearchBar;
@property (nonatomic, strong) UIAlertView       *alert;


@property (nonatomic, strong) NSArray *shortCutArray;
@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, assign) BOOL canVisitNewStore;

@property (nonatomic, strong) NSDictionary *shouldAddFilters;

@property (nonatomic, copy) NSString *storeInfoClassName;


@property (nonatomic, strong)WSFuncsBean *inPlanFuncsBean;
//存放当前环境包含的funcsBean
@property (nonatomic, strong)NSMutableDictionary *funcsBeanDic;

@property (nonatomic, assign)WSAllStoresCategory allStoreCategory;

@property (nonatomic, copy) NSString *subempid;

@property (nonatomic, strong) NSArray *allCitys;

@property (nonatomic,strong)WSAcvtSearchStoreView *acvtSearchStoreView;

@property (nonatomic,strong) WSAcvtBean *acvtBeanForSearchStore;

@property (nonatomic, assign) BOOL  isAutoEnterStorePage;

@property (nonatomic, strong) UIBarButtonItem *locationButton;
@property (nonatomic, copy) NSString *currentCity;

//@property (assign) CLLocationCoordinate2D               location;

@property (nonatomic , assign) NSInteger  pageNumer; // 第几页
@property (nonatomic , assign) NSInteger  titleNumer; // 标题门店数
@property (nonatomic , assign) BOOL isChooseCityViewDidAppear; // 是否是选择城市页面回来后
@property (nonatomic , assign) CGFloat distance;

@property (nonatomic , strong) WSAllStoreSectionView *sectionView;//段view

@property (nonatomic , strong) WSStoreHttpService * storeHttpService;  // 门店请求工具

@property (nonatomic , assign) BOOL isLocationFail; //yes 定位失败 NO 定位成功
@property (nonatomic , assign) BOOL isLoadingNearInfo; //yes 正在下载附近门店数据
@property (nonatomic , assign) BOOL isShowGpsOrNetError; //yes 显示定位或网络失败tip  NO 不显示

@property (nonatomic , strong) NSDictionary * conditions;
@property (nonatomic , strong) NSDictionary * rangeConditions;

@property (nonatomic , strong) NSArray  * needLoadList;  // 需要下载详情的门店列表




/**
 *  
 *
 *  @param funcs
 *  @param stores 店列表 (随访)
 *
 *  @return
 */
-(instancetype)initWithFuncs:(WSFuncsBean*)funcs Stores:(NSArray *)stores;

/**
 *
 *
 *  @param funcs
 *
 *  @return
 */
- (instancetype)initWithFuncs:(WSFuncsBean *)funcs;


- (void)initAllDataFromDb;

- (void)startUpdata:(WSStoreBean *)store;

- (void)startUpdata:(WSStoreBean*)store storeIds:(NSString *)storeIds;


//-(void)goNextWorkView;
-(void)goNextWorkView:(BOOL)plan;

- (NSString *)getObjIDToStoreInfo;

-(void)initOtherFuncsBean;
- (BOOL) isNewStorePage;
- (void) addOptMapView;

- (WSVisitStoreActionObject*) findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
                                        andCurrentVisitAction:(WSVisitStoreActionObject *)currentAction
                                                   andStoreId:(NSString *)store_id
                                             subMenuFuncsCode:(NSString *)subMenuFuncsCode;

- (void)didSelectStore:(WSStoreBean *)store  notification:(NSNotification *)notificaiton;

NSComparisonResult customSort(WSStoreBean * obj1, WSStoreBean * obj2,void* context);

- (void)addAllNavBBI;

- (void)clearAllNavBBI;

- (void)locationMe;

-(void)resetTitle;

-(void)addRefreshButton;

- (BOOL)isUploadGeoLocationInfo;

- (void)isShowEmptyView;

- (void)refreshData;

#pragma mark - 顶部下载详情和刷新清单这两个按钮的点击方法  YIHAIKERRY-3241
- (void)downloadNearStoreInfoData ;
- (void)refreshStoreList ;
- (void)closeProgressView;

- (void)searchOperationRefresh; //搜索操作刷新方法(针对子类刷新)

@end
