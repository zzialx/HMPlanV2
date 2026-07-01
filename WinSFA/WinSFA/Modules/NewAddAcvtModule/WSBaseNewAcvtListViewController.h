//
//  WSBaseNewAcvtListViewController.h
//  WinSFA
//
//  Created by yang on 15/12/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
#import "WSHeaderSearchView.h"

#define kRedisPCount 3
#define k_SearchHeaderViewDefaultHeight 44.0f
#define k_AddedHeight 26
#define LeftBarWidth 80.0
#define kStoreInfoDicKeyStoreinfo @"storeinfo"
#define kStoreInfoDicKeyAcvtID    @"acvt_id"
#define k_Remote_Notify @"remoteSearch"

typedef enum {
    // 保存本地数据
    WSSaveLocalData = 0,
    // 保存服务器返回数据
    WSSaveSeachedData
}WSSavedDataType;


@interface WSBaseNewAcvtListViewController : SuperWorkSpaceViewController<UITableViewDataSource, UITableViewDelegate,WSHeaderSearchViewDelegate>
{
    NSString *_subempid;
}


@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, assign) WSSavedDataType currentSaveDataType;
@property (nonatomic, assign) WSSearchRedisDataType currentSearchType;
@property (nonatomic, strong) NSArray *filterAcvts;// 新增调查问卷模板集合


@property (nonatomic, strong)WSHeaderSearchView *headerSearchView;
@property (nonatomic,assign) BOOL isCalenderPattern;

//for location
@property (nonatomic, strong) UIButton *locationBtn;
@property (assign)            CLLocationCoordinate2D  location;
@property (nonatomic, copy)   NSString *currentLocationString;
@property (nonatomic, assign) NSInteger locationSelectIndex;
@property (nonatomic, strong) NSString * currentSearchText;

@property (nonatomic, strong)NSArray *addAcvtArray;

@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, strong)NSString *searchText;

@property (nonatomic, assign) BOOL    isFirstLoad;

@property (nonatomic, strong) NSArray *selectedDates;

@property (nonatomic, strong) NSMutableArray *groupStyleDataArray;//分组时候数据源
@property (nonatomic, strong) NSMutableArray *cacheDataArray;//缓存分组时候数据源
@property (nonatomic, assign) BOOL isGroupStyle;//配置的是否显示分组样式
@property (nonatomic, assign) BOOL isBackShowRefresh; //是否需要返回刷新标示

// SFA-16444 此参数控制实时请求页面是否需要重新请求
@property (nonatomic, strong) NSString *needRefresh;
//@property (nonatomic, assign) BOOL isAddUnderTitleButton;   // MN-331 是否添加标题下按钮

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean;

- (void)setSubempid:(NSString*)empid;

- (NSArray *)getAcvtBeansWithFilter:(NSString *)filter;

- (WSAcvtBean *)filterAcvtBeanWithId:(NSString *)acvtId;

- (void)createHeaderSearchView;

- (void)reverseGeocodeLocation:(CLLocationCoordinate2D)aCLLocationCoordinate2D;

- (void)reloadData;

- (void)reloadDataWithDates:(NSArray *)dateStrs;

- (void)addDutyPlanNewAcvt:(WSAcvtBean *)acvtBean;
- (void) updateSMSButtonTitle;

/**
 刷新子类数据
 */
-(void)subclassReloadData;

/**
 重新刷新数据
 */
-(void)refreshData;

#pragma mark - 自动跳转下一个视图管理器方法 MN-1863_2018-04-19
- (void)autoJumpToNextViewController;

- (void)reloadDataFromDb;

@end
