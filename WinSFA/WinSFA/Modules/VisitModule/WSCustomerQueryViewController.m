//
//  CustomerQueryViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSCustomerQueryViewController.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
//#import "ConfigFileController.h"
#import "WSSearchBar.h"
#import "WSLocationArray.h"
#import "WSLocationSelectViewController.h"
#import "WSStoreInfoBeanArray.h"
#import "WSStoreAcvtDisBean.h"
#import "WinSFA.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSBaseStoreTable.h"
#import "WSStoreDataProcessService.h"
#import "WSEnvrionment.h"
#import "WSNewLocationSelectViewController.h"
#import "WSSearchStoreViewController.h"
#import "WSStoreBeans.h"
#import "WSBaseDictsDBService.h"

#import "WSBaseStoreOtherDataDBService.h"

#import "WSBaseStoreDBService.h"
#import "NSString+Additions.h"
#import "WSAcvtSearchStoreView.h"
#import "WSMJProgressHeader.h"
#import "WSAllStoreProgressView.h"
#import "WSDownloadDataProgressView.h"

#define CQ_NOTIFY           @"customerNotify"
#define UPDATA_NOTIFY       @"outPlan_notify"
#define kTableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))

//#define STORE_INFO @"custom_realtime_request_storeInfo"
#define STORE_SEARCH_OBJID @"custom_realtime_request_objId"

#define kLocateCityName       @"locate_cityName"

@interface WSCustomerQueryViewController ()<WSLocationNewSelectViewControllerDelegate> {
    UISearchBar *nbar;
    UIView *leftView;
    UIImageView *markImageView;
    
    NSTimer *_myTimer;
    float _sumTimer;
    NSInteger loadCount; //下载附近门店列表的数量
}
- (void)putUnleavedStoreToTop;

@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, copy) NSString *currentLocationString;
@property (nonatomic, assign) BOOL uploadGeoLocationInfo; // 上传经纬度标识
@property (nonatomic, strong) NSArray *filterLocationArray;
@property (nonatomic, strong) WSDictBean *selectedDictBean;
@property (nonatomic , strong) NSMutableDictionary * searchConditionDic;// 收索条件的
@property (nonatomic, assign) BOOL isPullRefresh; // 是否为下拉刷新请求，如果是，定位完成就要请求数据。
@property (nonatomic, assign) BOOL isFilter; // 是否有筛选条件

@property (nonatomic , copy) NSString *searchStoreType;  // 要搜索的门店的类型
@property (nonatomic , strong) WSAllStoreProgressView * progressView;
@property (nonatomic, strong) WSDownloadDataProgressView *listProgress;//门店列表的下载进度条
@property (nonatomic, strong) NSArray *empAreaCity; //YIHAIKERRY-3203 人员和授权城市的关系,只下载用户授权的城市的门店


@end

@interface WSCustomerQueryViewController (Tools)


@end

@implementation WSCustomerQueryViewController
@synthesize m_searchResult = _m_searchResult;
@synthesize filterLocationArray = _filterLocationArray;
// 初始化时 把偏好设置里 计划外门店的请求状态存入数组


-(void)viewDidLoad{
    [super viewDidLoad];

    self.isLoaded = NO;
    
    __weak typeof(self)weakSelf = self;
    self.tableView.mj_header = [WSMJProgressHeader headerWithRefreshingBlock:^{
        //YIHAIKERRY-3976 下拉重新定位并更新距离到数据库
        if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]){
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            NSString *tipsString = NSLocalizedString(@"refresh_prompt",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString  tips:nil tapTarget:self action:nil];
            [weakSelf needGps];
            
        }else {
            [weakSelf locationMe];
        }
        weakSelf.isPullRefresh = YES;
    }];

    
//    NSString *selectedCity = [[NSUserDefaults standardUserDefaults] stringForKey:SELECTED_CITY_NAME];
//    if (selectedCity) {
//        self.currentCity = selectedCity;
//    }
//
//    if ([self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto]) {
//        if (selectedCity) {
//            [self customQueryStartUpdata:nil];
//        }
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetWorkStateAndRefreshUI)
                                                 name:@"KCheckNetWork" object:nil];
    
    //YIHAIKERRY-3203  SFA 益海嘉里-传统渠道【门店列表】选择门店列表 按城市下载门店列表【变更_0813】
    if([self.currentFuncs.opt.downByMap isEqualToString:@"2"]){
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSArray *arrCity = [service queryCityDownLoadList];
        self.empAreaCity = [arrCity valueForKeyPath:@"name"];
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //益海嘉里200家门店新功能，检测网络，无网络弹出提示
    [self checkNetWorkStateAndRefreshUI];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.tableView.mj_header endRefreshing];
    
    self.isLoaded = YES;
    
    //YIHAIKERRY-5262 益海嘉里-上海：潜力客户：手动更换城市后，再次点击该模块，不能自动刷新出此时所在城市
    [[NSUserDefaults standardUserDefaults]  removeObjectForKey:SELECTED_CITY_NAME];

}
- (void)loadView
{
    [super loadView];
    
    _uploadGeoLocationInfo = [self isUploadGeoLocationInfo];
    
// MSTD-7155 改为所在城市
//    if (self.currentCity.length > 0) {
//
//    }else
//        self.currentCity = NSLocalizedString(@"beijing", nil);
    
//    if (_currentLocationString.length > 0) {
    
//    }else
//        _currentLocationString = NSLocalizedString(@"beijing", nil);
    
//    if (_uploadGeoLocationInfo) {
//        [self locationMe];
//    }
}

 // YIHAIKERRY-1991
-(void)searchAutoRequest{
    //    YIHAIKERRY-3410 董宏 益海嘉里的特殊处理
    if([self.currentFuncs.opt.downByMap isEqualToString:@"2"])
    {
       if(![[WSBaseStoreTable sharedTable] queryStoresWithSearchCode:self.currentCity] && [self.empAreaCity containsObject:self.currentCity]) //YIHAIKERRY-3203 用户授权了当前城市 才下载 --张敏
        {
            [self customQueryStartUpdata:nil];
            self.isPullRefresh = NO;
        }
    }
    else
    {
        if ((!self.isLoaded && self.currentLocationString && [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto]) ||self.isPullRefresh) {
            [self customQueryStartUpdata:nil];
            self.isPullRefresh = NO;
        }
    }
   
}
- (UIView *)getTableHeaderView {
    _uploadGeoLocationInfo = [self isUploadGeoLocationInfo];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.autoresizesSubviews = NO;
    
    if (_uploadGeoLocationInfo) {
        if ([[UIDevice currentDevice] systemVersionNotLowerThan:@"7.0"])
        {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            CGFloat leftView_origin_x = INTERFACE_IS_PHONE ? 0 :175;
            leftView = [[UIView alloc] initWithFrame:CGRectMake(leftView_origin_x, 0, LeftBarWidth, 44)];
            self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
            _locationBtn.showsTouchWhenHighlighted = YES;
            _locationBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            NSString *title = NSLocalizedString(@"select_city", nil);
//            [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
            [_locationBtn setTitle:title forState:UIControlStateNormal];
            [_locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
             [_locationBtn setTitleColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
            [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [leftView addSubview:_locationBtn];
            
            markImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
            markImageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
            markImageView.contentMode = UIViewContentModeRight;
            [leftView addSubview:markImageView];
            [headerView addSubview:leftView];
#else
            
            nbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LeftBarWidth, 44)];
            for (UIView *view in nbar.subviews) {
                if ([view isKindOfClass:[UITextField class]]) {
                    [view removeFromSuperview];
                }
            }
            self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
            _locationBtn.showsTouchWhenHighlighted = YES;
            _locationBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            NSString *title = NSLocalizedString(@"select_city", nil);
            [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
            [_locationBtn setTitle:title forState:UIControlStateNormal];
            [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [nbar addSubview:_locationBtn];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
            imageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
            imageView.contentMode = UIViewContentModeRight;
            [nbar addSubview:imageView];
            [headerView addSubview:nbar];
#endif
            
        }
        else
        {
            nbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LeftBarWidth, 44)];
            nbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            for (UIView *view in nbar.subviews) {
                if ([view isKindOfClass:[UITextField class]]) {
                    [view removeFromSuperview];
                }
            }
            self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
            _locationBtn.showsTouchWhenHighlighted = YES;
            _locationBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            NSString *title = NSLocalizedString(@"select_city", nil);
            [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
            [_locationBtn setTitle:title forState:UIControlStateNormal];
            [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [nbar addSubview:_locationBtn];
            
            markImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
            markImageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
            markImageView.contentMode = UIViewContentModeRight;
            [nbar addSubview:markImageView];
            [headerView addSubview:nbar];
        }
        
//        _currentLocationString = NSLocalizedString(@"beijing", nil);
        
    }
    
    float xoffset = _uploadGeoLocationInfo ? LeftBarWidth : 0.0;
    float width = self.view.bounds.size.width - xoffset;
    self.ownSearchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(xoffset, 0.0, width, 44.0) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar.searchBar.delegate = self;
    self.ownSearchBar.searchBar.placeholder = self.currentFuncs.opt.searchHint;
    if (self.currentFuncs.opt.searchHint.length == 0) {
        self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_hint_label", nil);
    }
    if (INTERFACE_IS_PHONE) {
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView  addSubview:self.ownSearchBar];
    if (_uploadGeoLocationInfo) {
         [self locationMe];
    }
    return headerView;
}



/**
 *  从字典表节点里获取城市数据
 *
 *
 *  @return <#return value description#>
 */

- (void)locationButtonClicked
{

    [self showChooseCityViewController];
}

- (void)locationBtnClick:(id)sender {
    
    [self showChooseCityViewController];
}

- (void)showChooseCityViewController
{
   //和安卓统一逻辑
    if ([self.currentFuncs.opt.isOpenGeo isEqualToString:@"N"] || self.currentFuncs.opt.isCurrentGeo) {
        return;
    }
    if (self.allCitys == nil) {
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSString *levelCod = self.currentFuncs.opt.gpsCityLevel ? self.currentFuncs.opt.gpsCityLevel : @"2";
        self.allCitys = [service queryCityListByFilter:@"geography" levelCode:levelCod];
    }
    
    if ([self.allCitys count] > 0) {
        WSNewLocationSelectViewController *lsvc = [[WSNewLocationSelectViewController alloc] initWithCurrentLocation:_currentLocationString selectedItem:self.selectedDictBean dicts:self.allCitys];
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:lsvc];
        lsvc.selectDelegate = self;
        [self presentViewController:navc  animated:YES completion:nil];
    }
}

- (NSString *)getSelectedCityName {
    NSString *currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:SELECTED_CITY_NAME];
    if (!currentCity) {
        currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];;
    }
    return currentCity;
}

- (void)setBarButtonTitle {
    NSString *currentCity = [self getSelectedCityName];
    if (!currentCity) {
        currentCity = NSLocalizedString(@"select_city", nil);
    }
    if (currentCity.length > 4) {
        NSString  *temString = [currentCity substringToIndex:3];
        currentCity = [NSString stringWithFormat:@"%@...",temString];
    }
    [self.locationButton setTitle:currentCity];
    // MSTD-6966 
    [UIView animateWithDuration:0.4 animations:^{
        self.ownSearchBar.alpha = 1;
    }];
}


- (void)viewController:(WSNewLocationSelectViewController *)viewController didselectedItem:(WSDictBean *)item {
    
    if (item == nil ) {
        if (_currentLocationString) {
            [_locationBtn setTitle:_currentLocationString forState:UIControlStateNormal];
            self.currentCity = _currentLocationString;
            [self setBarButtonTitle];
//            SFA-18922 donghong
//            self.m_searchResult = [NSMutableString stringWithString: _currentLocationString];
        }
    }else {
//        self.m_searchResult = [NSMutableString stringWithString:item.name];
        self.selectedDictBean = item;
        NSString *cityName = item.name;
        [_locationBtn setTitle:cityName forState:UIControlStateNormal];
        self.currentCity = cityName;
        [self setBarButtonTitle];
        [self  resetLocationBtnAndSearchBarWidthWithTitle:cityName font:16.0f];
    }
    if (self.currentCity) {
        [[NSUserDefaults standardUserDefaults] setObject:self.currentCity forKey:SELECTED_CITY_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self  customQueryStartUpdata:nil];
        self.isChooseCityViewDidAppear = YES;
    }
}
// ios6  ios7  搜索框左侧字体长度自适应
- (void)resetLocationBtnAndSearchBarWidthWithTitle:(NSString *)title font:(CGFloat)font {
    //
    UIFont *titleFont = [UIFont systemFontOfSize:font];
//    CGSize size = CGSizeMake(320,44);
    CGSize titleSize = [title ws_sizeWithFont:titleFont constrainedToHeight:44];
    if ([[UIDevice currentDevice] systemVersionNotLowerThan:@"7.0"]) {
        CGFloat newWidth = titleSize.width + 32;
        CGRect newRect = CGRectMake(0, 0, newWidth, 44);
        CGFloat newX = INTERFACE_IS_PAD ? CGRectGetMinX(self.ownSearchBar.frame) - newWidth : 0;
        if (newX < 0) {
            newX = 0;
        }
        leftView.frame = CGRectMake(newX , 0, newWidth, 44);
        [_locationBtn setFrame:newRect];
        _locationBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [markImageView setFrame:newRect];
        markImageView.contentMode = UIViewContentModeRight;
        self.ownSearchBar.frame = CGRectMake(titleSize.width + 32, 0,self.view.bounds.size.width - titleSize.width - 32 , 44);
    } else {
        nbar.frame = CGRectMake(0, 0, titleSize.width + 32, 44);
        _locationBtn.frame = CGRectMake(0, 0, titleSize.width + 32, 44);
        _locationBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        markImageView.frame = CGRectMake(0, 0, titleSize.width + 32, 44);
        markImageView.contentMode = UIViewContentModeRight;
        self.ownSearchBar.frame = CGRectMake(titleSize.width + 32, 0,self.view.bounds.size.width - titleSize.width - 32 , 44);
    }
   
}
- (void)resetLocation:(NSString *)administrativeArea locality:(NSString *)locality subLocality:(NSString *)subLocality {
//    if(self.sectionView)
//    {
//        self.sectionView.address = self.locationDescribe.detailAddress;
//    }
    if (locality) {
        _currentLocationString = locality;
    } else if (administrativeArea) {
        _currentLocationString = administrativeArea;
    }
    
    NSString *lastCurrentCity = [[NSUserDefaults standardUserDefaults] objectForKey:kLocateCityName];
    if (![lastCurrentCity isEqualToString:locality]) {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:SELECTED_CITY_NAME];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_currentLocationString forKey:kGlobalCityName];
    [[NSUserDefaults standardUserDefaults] setObject:_currentLocationString forKey:kLocateCityName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
 
    self.currentCity = _currentLocationString;
    [self setBarButtonTitle];
    
    if (self.allCitys == nil) {
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSString *levelCod = self.currentFuncs.opt.gpsCityLevel ? self.currentFuncs.opt.gpsCityLevel : @"2";
        self.allCitys = [service queryCityListByFilter:@"geography" levelCode:levelCod];
        
        self.selectedDictBean = [[self.allCitys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@",self.currentCity]] firstObject];
    }else if (self.allCitys.count > 0 && [self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {
        //YIHAIKERRY-3201
        self.selectedDictBean = [[self.allCitys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@",self.currentCity]] firstObject];
    }
    
    NSString *selectedCity = [[NSUserDefaults standardUserDefaults] stringForKey:SELECTED_CITY_NAME];
    if (!selectedCity) {
        self.currentCity = locality;
        [self searchAutoRequest];
    }
     //定位成功，刷新状态  downbymap =2时
     [self checkNetWorkStateAndRefreshUI];
 }

- (void)saveSearchObjId:(NSString *)objId {
    /**/
    NSMutableDictionary  *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringNotNilWithValue:objId] forKey:@"objId"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dictionary forKey:OUT_PAN_SEARCH_STORE];
    [userDefaults synchronize];
}

-(void)resetDataSources{
        NSString *currenteEmpId = [self getCurrentEmpId];
        NSString *subEmpId = self.subempStore.Id;
        NSString *empId = subEmpId?:currenteEmpId;
        NSString *funCode = self.currentFuncs.fc;
  

        NSString *stringKey = self.storeHttpService.objID;
        if (self.subMenuFuncsCode) {
            funCode = self.subMenuFuncsCode;
        }
    
    NSString *search_ObjCode_Code = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];

    if([self.currentFuncs.iParentFuncsBean.opt.isSrid isEqualToString:@"0"])
    {
        subEmpId = nil;
//        self.subempStore = nil;
        empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
        //MN-1578 2018-04-08
        BOOL isSearchable = ([self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote] ||
                             [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto]);
        //BOOL isSearchable  = [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote];
    
    //  donghong 与安卓逻辑一致 在离线情况下 显示所有的门店没有 code的限制 YIHAIKERRY-2609
    if ([self isResetSearchObjCode]) {
        search_ObjCode_Code = self.m_searchResult.length > 0 ? self.m_searchResult : nil ;
        isSearchable = NO;
    }
    //    MN-3148
    //    【后台】城市经理手机端四级拜访筛选条件和搜索门店问题，见描述。
    NSString *styp = self.searchStoreType.length > 0 ? self.searchStoreType : self.currentFuncs.styp;

    self.titleNumer = [[WSBaseStoreDBService shareInstance] queryAllStoreCountEmpId:empId styp:styp searchStr:search_ObjCode_Code search_objId:stringKey isSearchable:isSearchable acvtId:[self resetAcvtIdString] selctedQstValues:self.conditions.mutableCopy rangeConditions:self.rangeConditions distance:self.distance otherDataDic:nil];
    NSArray *searchedStore =[[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId styp:styp searchStr:search_ObjCode_Code search_objId:stringKey isSearchable:isSearchable storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal acvtId:[self resetAcvtIdString] selectedQstValues:self.conditions.mutableCopy rangeConditions:self.rangeConditions distance:self.distance pageNumber:self.pageNumer distanceSort:self.currentFuncs.opt.distancesSort otherDataDic:nil parentStoreFc:self.currentFuncs.opt.parentStoreFc];

    
        if (searchedStore.count < kStoreListPageCount) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    
        // YIHAIKERRY-2926 这里设置为 NO 后跳出该页面再返回有问题
//        self.isFilter = NO;
    
        self.filterArray =  [NSMutableArray arrayWithArray:searchedStore];
        [self isShowEmptyView];
    
        [self.tableView reloadData];
    
        [self resetTitle];
    
        // 搜索出来的门店数量
        [self saveRequestedStoreCount];
}
- (void)saveRequestedStoreCount {
    if ([self.filterArray count] > 0) {
        NSInteger requestStoreCount = [self.filterArray count];
        NSNumber *requestStoreNum = [NSNumber numberWithInteger:requestStoreCount];
        [FileManager setUserDefaults:requestStoreNum forKey:CUSTOMQUERYSTORES];
    }
}


- (void)putUnleavedStoreToTop {
    // 如已经完成开始拜访但没有完成结束拜访的店 则把此店放的index置为0
    BOOL  containSaveStore = NO;
    NSString * storeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"EnterAndNotLeaveId"];
    if (storeId) {
        NSInteger index = 0;
        if (storeId) {
            for (NSInteger i =0; i <[self.filterArray count]; i++) {
                WSStoreBean *storeBean = [self.filterArray objectAtIndex:i];
                if ([storeBean.Id isEqualToString:storeId]) {
                    index = i;
                    containSaveStore = YES;
                }
            }
            if (index != 0 && containSaveStore) {
                [self.filterArray exchangeObjectAtIndex:index withObjectAtIndex:0];
            }
        }
    }
}

// 根据数据给用户显示部分提示
-(void)giveUserSomeTipsWithDic:(NSDictionary *)dic{
    BOOL isRealCount = YES;
    if ([self.filterArray count] > 0) {
        
        WSStoreBean *storeBean = [self.filterArray objectAtIndex:0];
        if ([storeBean.inArray count] > 0) {
            NSDictionary *dic = [storeBean.inArray objectAtIndex:0];
            NSString *numberString = [NSString stringWithValue:[dic objectForKey:@"num"]];
            NSInteger number = [numberString integerValue];
            if (number > 0 && [self.filterArray count] < number) {
                isRealCount = NO;
            }
        }
    }
    NSString *tmpString = nil;
    if ([self.filterArray count] > 0) {
        if (isRealCount) {
            //                tmpString = NSLocalizedString(@"update_done_label",nil);
            //                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        }
        else
        {
            tmpString = [NSString stringWithFormat:NSLocalizedString(@"search_too_much", nil),[self.filterArray count]] ;
        }
        if (![dic objectForKey:@"autostoreinfo"] && [self.currentFuncs.opt.downByMap isEqualToString:@"2"]) { //当前城市没有门店，但是下载了其他城市的门店，所以count>0
            tmpString = NSLocalizedString(@"no_store_in_city", nil);
        }
    } else {
        if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {
            tmpString = NSLocalizedString(@"no_store_in_city", nil);
        }else{
            tmpString = NSLocalizedString(@"no_result", nil);
        }
    }
    
    if (tmpString) [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
   
}

-(void)customQueryStartUpdata:(WSStoreBean*)store
{
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(searchFinished:)
//                                                 name:CQ_NOTIFY
//                                               object:nil];
//    [self requestMethed:store];
    //    donghong MMSH-3917 实时请求需要 把页码归0
    self.pageNumer = 0;
    if (!self.isPullRefresh) {
        if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {  //益海嘉里200家门店功能，弹出特定进度条 --zhangmin
            [self initListProgress];
        }else {
            [self querying_messageTips];
        }
    }
    self.storeHttpService.objID = [self getObjIDToStoreList];
    self.storeHttpService.currentFunc = self.currentFuncs;
    self.storeHttpService.currentCity = self.currentCity;
    //MN-3979 蒙牛（ios）-四级拜访-选择市场查询后-再选择其他市场，之前第一次选择的市场仍显示(需要把搜索条件赋值过去，等请求回来的时候存起来，查询显示的时候根据搜索条件查询)
    //SFA-25219
    self.storeHttpService.searchString = self.m_searchResult.length > 0 ? self.m_searchResult:[self.searchConditionDic JSONString] ;
    if ([_currentLocationString isEqualToString:self.currentCity]) {
        self.storeHttpService.location = self.locationDescribe.location.coordinate;
    }else {
        self.storeHttpService.location =  CLLocationCoordinate2DMake(0, 0);;
    }
//    self.storeHttpService.location = self.locationDescribe.location.coordinate;
    
    self.storeHttpService.subMenuFuncsCode = self.subMenuFuncsCode;
    //    SFA-17862
    //    SFA-东莞鸿兴--ios端--工作--上级拜访--门店列表--点进来时不需要显示门店，需要实时请求门店
    self.storeHttpService.subEmpStoreBean = self.subempStore;
    self.storeHttpService.isUploadLocationInfo = _uploadGeoLocationInfo;
    self.storeHttpService.searchConditionDic = self.searchConditionDic;
    self.storeHttpService.cityCode = self.selectedDictBean.Id;
    self.storeHttpService.distance = self.distance;
    self.storeHttpService.downLoadStoreListType = WSCQVC_QUERY_STORE_CITY_LIST;
    BOOL serchCode =  [[WSBaseStoreTable sharedTable] queryStoresWithSearchCode:self.currentCity];
    self.storeHttpService.filterString = [self.searchConditionDic JSONString];

    //YIHAIKERRY-2888
    CLLocationCoordinate2D tempLocation = self.storeHttpService.location;
    if([self.currentFuncs.opt.downByMap isEqualToString:@"1"]||[self.currentFuncs.opt.downByMap isEqualToString:@"2"] )
    {
        double distance = [[[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_STORE_RANGE] doubleValue];
        
        CLLocationCoordinate2D location0 = [WSLocationDescribe getOffLocationWithAngle:0 distance:distance location:tempLocation];
        CLLocationCoordinate2D location180 = [WSLocationDescribe getOffLocationWithAngle:180 distance:distance location:tempLocation];
        CLLocationCoordinate2D location90 = [WSLocationDescribe getOffLocationWithAngle:90 distance:distance location:tempLocation];
        CLLocationCoordinate2D location_90 = [WSLocationDescribe getOffLocationWithAngle:-90 distance:distance location:tempLocation];
        
        self.storeHttpService.maxLat = location0.latitude;
        self.storeHttpService.minLat = location180.latitude;
        self.storeHttpService.maxLon = location90.longitude;
        self.storeHttpService.minLon = location_90.longitude;
    }
    
    __weak typeof(self)weakSelf = self;
    // 请求门店数据
    [self.storeHttpService getCustomerQueryStoreListDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
        
        if (dic && !error) {
            weakSelf.isChooseCityViewDidAppear = NO;
            [weakSelf resetDataSources];
            [weakSelf giveUserSomeTipsWithDic:dic];
            [weakSelf.tableView.mj_header endRefreshing];
            
            if ([self.currentFuncs.opt.downByMap isEqualToString:@"1"])
            {
                //YIHAIKERRY-2946 (经和服务器讨论 在没有门店id数组时<updateStoreInfo方法内设定> 无需再次请求)
                BOOL isTwoRequest = [weakSelf updateStoreInfo];
                if(isTwoRequest)
                    return; //YIHAIKERRY-2791 发生2次请求的情况下 return 防止hud消失
            }
            self.listProgress.progress = 100;
        }else {
            if ( [self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {
                [self.listProgress  closeListProgress];
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
                NSString *tipsString = NSLocalizedString(@"storelist_download_failure", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
        }
//        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    }];
    
}

//下载附近10家的门店详细数据 YIHAIKERRY-3201 SFA 益海嘉里-现代渠道【门店拜访】200以上门店数据加载方案YIHAIKERRY-3203
- (void)downloadTenStoreInfoData {
    
    self.isLoadingNearInfo =YES;
    
    NSMutableArray *storeArray = [NSMutableArray array];
    storeArray = [self.filterArray mutableCopy];
    
    NSArray *temArray = [NSMutableArray array];
    if (storeArray.count > 10) {
        temArray = [storeArray subarrayWithRange:NSMakeRange(0, 10)];
    }else {
        temArray = storeArray;
    }
    
    NSString *storeIds = [self getStoreIdsWithStoreList:temArray];
    
    if(storeIds.length <= 0) return ;
    [self startUpdata:nil storeIds:storeIds];
    
    
    _sumTimer = 0;
    loadCount = 10;
    [self initProgressView];
    
}

- (void)initProgressView{
    
    self.progressView =  [[WSAllStoreProgressView alloc] initWithSelect:loadCount];
    [self.progressView  showXLAlertView];
    _myTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES]; //< 需要加入手动RunLoop，需要注意的是在NSTimer工作期间self是被强引用的
    [[NSRunLoop currentRunLoop] addTimer:_myTimer forMode:NSRunLoopCommonModes]; //< 使用NSRunLoopCommonModes才能保证RunLoop切换模式时，NSTimer能正常工作。
}
//YIHAIKERRY-3590 SFA 益海嘉里-传统渠道【门店列表】自动和手动加载门店列表、门店下载中心下载门店列表， 增加进度的显示效果
- (void)initListProgress {
    self.listProgress =  [[WSDownloadDataProgressView alloc] initWithSelect:loadCount];
    [self.listProgress  showDownListAlertView];
}
#pragma mark - 顶部下载详情和刷新清单这两个按钮的点击方法  YIHAIKERRY-3241
//下载附近100家的门店详细数据
- (void)downloadNearStoreInfoData {
    
    if (self.isShowGpsOrNetError) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *tipsString = NSLocalizedString(@"network_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    self.isLoadingNearInfo =YES;
    
    NSMutableArray *storeArray = [NSMutableArray array];
    //配置中的最大下载数量
    NSInteger maxLoadNum = [self.currentFuncs.opt.downloadInfoNum  integerValue];
    NSInteger Needpage =  maxLoadNum/kStoreListPageCount;
    NSInteger mol =maxLoadNum % kStoreListPageCount;
    if (mol > 0) {
        Needpage = Needpage +1;
    }
    
    //数组不够，从数据库中取；
    if (self.filterArray.count < self.titleNumer&& self.filterArray.count < maxLoadNum) {
        for (int i = 0; i< Needpage; i++) {
            NSArray *searchedStore = [self getFilterArrayWithPageNumber:i];
            [storeArray addObjectsFromArray:searchedStore];
              if (searchedStore.count < kStoreListPageCount) {
                  break;
              }
        }
        
    }else {
        storeArray = [self.filterArray mutableCopy];
    }

    NSArray *temArray = [NSArray array];
    if (storeArray.count > maxLoadNum) {
        temArray = [storeArray subarrayWithRange:NSMakeRange(0, maxLoadNum)];
    }else {
        temArray = storeArray;
    }

    NSString *storeIds = [self getStoreIdsWithStoreList:temArray];

    if(storeIds.length <= 0) return ;
    [self startUpdata:nil storeIds:storeIds];
    
    _sumTimer = 0;
    loadCount = temArray.count; //需要下载详情的门店列表数量
    self.needLoadList = temArray; //需要下载详情的门店列表
    
    [self initProgressView];
    
}
//更新城市门店清单
-(void)refreshStoreList {

    if (self.isShowGpsOrNetError) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *tipsString = NSLocalizedString(@"network_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    
    //    //添加进度条
    [self initListProgress];
    [self requestRefreshStoreList];
    
}

-(void)requestRefreshStoreList{
    self.isPullRefresh= YES;
    [self customQueryStartUpdata:nil];
    self.isPullRefresh = NO;
}

//虚拟进度条 SFA益海嘉里YIHAIKERRY-3368，提示信息窗进度开始是一点一点加载，然后停顿在一个值上不动
-(void)timerFired:(NSTimer *)timer {
    if (loadCount <= 10) {
        int i = arc4random() % 4;
        _sumTimer += i;
    }
    else if (loadCount >= 50)
    {
        int i = arc4random() % 15;
        _sumTimer += i;
    }
    else
    {
        _sumTimer += 0.4;
    }
    self.progressView.progress = loadCount > _sumTimer ? _sumTimer : loadCount-1;
}
- (void)closeProgressView
{
    [_myTimer invalidate];
    _myTimer = nil;
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
}

//判断有无网络,定位失败是否显示，刷新tableview
- (void)checkNetWorkStateAndRefreshUI
{
    if(![self.currentFuncs.opt.downByMap isEqualToString:@"2"]) return;
    
    BOOL isShow = NO;//定位是否成功，yes失败 NO成功
    BOOL netIsError = [self checkNetworkIsError];
    
    if (!self.locationDescribe.location) {
        isShow = YES;
    }
    
    if (isShow || netIsError) {//定位或网络失败，则显示tip
        self.isShowGpsOrNetError  = YES;
    }else {
        self.isShowGpsOrNetError  = NO;
    }
    
    if (self.isLocationFail != isShow) {
        self.isLocationFail = isShow;
        [self.tableView reloadData];
    }
}

//判断网络连接，yes没有网络
- (BOOL)checkNetworkIsError {
    BOOL netIsError = NO;
    Reachability *r =[Reachability reachabilityWithHostname:@"www.baidu.com"];
    if ([r currentReachabilityStatus] == NotReachable) {
        netIsError = YES;
    }
    return netIsError;
}

#pragma mark - 封装获取列表的方法
-(NSArray *)getFilterArrayWithPageNumber:(NSInteger) pageNumer {
    
    NSString *stringKey = [self getObjIDToStoreList];
    NSString *currenteEmpId = [self getCurrentEmpId];
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = subEmpId?:currenteEmpId;
    NSString *funCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    NSString * search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    NSString *searchObjCode = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];
    BOOL isRemoteSearch  = [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote];
    NSArray *searchedStore;
    //        donghong 与安卓逻辑一致 在离线情况下 显示所有的门店没有 code的限制 YIHAIKERRY-2584
    if ([self isResetSearchObjCode] || (!self.isLoaded)) {
        searchObjCode = self.m_searchResult.length > 0 ? self.m_searchResult : nil ;
    }
    if([self.currentFuncs.iParentFuncsBean.opt.isSrid isEqualToString:@"0"])
    {
        empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
    searchedStore  =[[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:searchObjCode search_objId:stringKey isSearchable:isRemoteSearch storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal acvtId:[self resetAcvtIdString] selectedQstValues:self.conditions.mutableCopy rangeConditions:self.rangeConditions distance:self.distance pageNumber:pageNumer distanceSort:self.currentFuncs.opt.distancesSort otherDataDic:nil parentStoreFc:self.currentFuncs.opt.parentStoreFc];
    
    return  searchedStore;
}
-(void)getTitleNumerFromDB {
    NSString *stringKey = [self getObjIDToStoreList];
    NSString *currenteEmpId = [self getCurrentEmpId];
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = subEmpId?:currenteEmpId;
    NSString *funCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    NSString * search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    NSString *searchObjCode = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];
    BOOL isRemoteSearch  = [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote];
  
    if ([self isResetSearchObjCode]) {
        searchObjCode = self.m_searchResult.length > 0 ? self.m_searchResult : nil ;
    }
    if([self.currentFuncs.iParentFuncsBean.opt.isSrid isEqualToString:@"0"])
    {
        empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
    self.titleNumer = [[WSBaseStoreDBService shareInstance] queryAllStoreCountEmpId:empId styp:self.currentFuncs.styp searchStr:searchObjCode search_objId:stringKey isSearchable:isRemoteSearch acvtId:[self resetAcvtIdString] selctedQstValues:self.conditions.mutableCopy rangeConditions:self.rangeConditions distance:0 otherDataDic:nil];
}

//获取SearchObjCode
- (NSString *)getSearchObjCode {
    NSString *currenteEmpId = [self getCurrentEmpId];
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = subEmpId?:currenteEmpId;
    NSString *funCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    
    NSString *searchObjCode = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];
    //        donghong 与安卓逻辑一致 在离线情况下 显示所有的门店没有 code的限制 YIHAIKERRY-2584
    if ([self isResetSearchObjCode]) {
        searchObjCode = self.m_searchResult.length > 0 ? self.m_searchResult : nil ;
    }
    return searchObjCode;
}

//donghong 与安卓逻辑一致 在离线情况下 显示所有的门店没有 code的限制 YIHAIKERRY-2584
-(BOOL)isResetSearchObjCode {
    return (([self.currentFuncs.opt.downByMap isEqualToString:@"1"]  && !self.isFilter ) || [self.currentFuncs.opt.downByMap isEqualToString:@"2"]);
}


/**
 用于下载门店详情数据的storeids
 @param storeList 需要下载详情数据的门店list数组
 @return 门店id拼接成的字符串
 */
-(NSString *)getStoreIdsWithStoreList:(NSArray*)storeArray
{
    NSMutableString *storeIds = [NSMutableString stringWithCapacity:0];
    //顺序遍历
    for (int i = 0; i < storeArray.count; i++) {
        WSStoreBean * obj = storeArray[i];
        if (i ==0)
        {
            [storeIds appendFormat:@"%@", obj.Id];
        }
        else
        {
            [storeIds appendFormat:@",%@",obj.Id];
        }
    }
    
    return storeIds;
}


#pragma mark - ------

- (BOOL)updateStoreInfo
{
    NSString *storeIds = [self getStoreIdsWithStoreList:self.filterArray];
    //YIHAIKERRY-2946
    if(storeIds.length <= 0)
        return NO;
    
    [self startUpdata:nil storeIds:storeIds];
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(self.m_searchResult == nil)
        _m_searchResult = [[NSMutableString alloc]init];
    [self.m_searchResult setString:searchText];
    
    //SFA益海嘉里YIHAIKERRY-3346 进入门店列表，门店加载完成，输入搜索条件，不对加载出的门店进行筛选
    if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]){
        // YIHAIKERRY-3490 下载其他城市门店后无法搜索到 所以屏蔽判断本地是否有当前城市的逻辑
        //判断是否存在已下载数据,本地有数据就搜索本地，本地没有数据，就发请求
//        if ([[WSBaseStoreTable sharedTable] queryStoresWithSearchCode:self.currentCity]){
            [self reloadStoreList];
//        }else{
//            [self customQueryStartUpdata:nil];
//        }
    }else{
        // SFA-14320 by liran 跟 WSAllStoreViewController 操作一致点清除按钮重新加载数据
        if (searchBar.text.length == 0) {
            [self customQueryStartUpdata:nil];
        }
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (![self.currentFuncs.opt.downByMap isEqualToString:@"2"]){
        [self customQueryStartUpdata:nil];
    }
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSString * searchString = [self.currentFuncs.opt.searchQuestion lowercaseString];
    if (searchString && [searchString isEqualToString:@"dateselect"]) {
        
        NSString *selectedCityName = self.selectedDictBean.name ?: _currentLocationString;
        WSSearchStoreViewController *searchStoreViewController = [[WSSearchStoreViewController alloc]initWithCityName:selectedCityName searchContent:self.m_searchResult];
        searchStoreViewController.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchStoreViewController];
        
        [self presentViewController:nav animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    /*Jira - MSTD-7292 create by sunhongfu*/
  //  [searchBar setShowsCancelButton:YES animated:YES];
    //    searchBar.layer.anchorPoint = CGPointMake(320, searchBar.layer.anchorPoint.y);
    
//    searchBar.text = @" ";
    self.m_searchResult = [NSMutableString stringWithString:@""];

    if (searchBar.text.length > 0) {
        self.m_searchResult = searchBar.text.mutableCopy;
    }

    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
//                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                break;
            }
        }
        
    }
    
    /**/
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];

    if (searchBar.text.length == 0) {
        searchBar.text = nil;
        self.m_searchResult = nil;
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    
    // SFA-14320 by liran
    [self customQueryStartUpdata:nil];
}

#pragma mark - View lifecycle
- (void)initAllDataFromDb {
    
    [self initOtherFuncsBean];
    
//    /*重写父类 时候搜索出来的门店 再次进入不显示*/
//    BOOL isAutoSearch = [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto];
//    if (isAutoSearch && !self.isLoaded) {
//        // autoSearch 需要实时请求，不从数据库中加载数据
//        return;
//    }

    BOOL isRemoteSearch  = [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote];
    
    NSArray *searchedStore;
    NSString *searchObjCode = [self getSearchObjCode];
    
    if (isRemoteSearch) {
         //MMSH-8191
        //备注：因为手动点击搜索searchObj为空的时候没存
            // 第一次进入列表 列表显示空
            if (!self.isLoaded) {
                self.isLoaded = YES;
            }else{
                // 查询门店的条数
                [self getTitleNumerFromDB];
                //获取分页列表
                searchedStore  = [self getFilterArrayWithPageNumber:self.pageNumer];
            }
    }else {
        // 查询门店的条数
        [self getTitleNumerFromDB];
        //获取分页列表
        searchedStore  = [self getFilterArrayWithPageNumber:self.pageNumer];
    }
    if (searchedStore.count < kStoreListPageCount) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }

    [self.filterArray addObjectsFromArray:searchedStore];
    [self isShowEmptyView];

    if (self.filterArray && self.filterArray.count > 0) {
        NSString* empId = [self getCurrentEmpId];
        
        for (WSStoreBean *storeBean in self.filterArray) {
            if (self.subempStore.Id && self.subempStore.Id.length > 0 && ![self.subempStore.Id isEqualToString:empId]) {
                storeBean.srid = self.subempStore.Id;
            }
        }
    }
}

#pragma mark - MN-1578 2018-04-08 根据最新逻辑点击计划外门店查看详情时做修改(以下为wiki地址)
#pragma mark - http://wiki.winchannel.net/xwiki/bin/view/%E4%BA%A4%E4%BB%98%E5%B9%B3%E5%8F%B0/SFA%E4%BA%A4%E4%BB%98/SFA%E5%AE%A2%E6%88%B7%E7%AB%AF%E6%96%87%E6%A1%A3/%E5%BC%80%E5%8F%91%E6%96%87%E6%A1%A3/%E9%97%A8%E5%BA%97%E5%88%97%E8%A1%A8/%E5%8F%82%E6%95%B0%E9%85%8D%E7%BD%AE/
- (NSString *)getObjIDToStoreList
{
    //SFA-8371 原来加这个逻辑的jira号
    //MN-3539 屏蔽代码的jira号
    //备注：安卓没有这个判断

//    if (self.currentFuncs.funcsArray != nil && [self.currentFuncs.funcsArray count] == 1)
//    {
//        WSFuncsBean *tempSub = [self.currentFuncs.funcsArray firstObject];
//        if ([tempSub.fv isEqualToString:self.currentFuncs.fv])
//        {
//            if ([tempSub.filter length] > 0)
//                return  tempSub.filter;
//        }
//    }
    
    if ([self.currentFuncs.filter length] > 0)
        return self.currentFuncs.filter;
    
    if (_uploadGeoLocationInfo)
        return @"autostoreinfo";
    
    if([self.currentFuncs.fv isEqualToString:FV_TAB_V21001])
        return  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    else if([self.currentFuncs.fv isEqualToString:@"TAB_V13001"])
        return @"subempoutstore";
    else
        return @"allplanstoreontime";
    
    return nil;
}

- (void)addUpdateStoreInfoToAppdata:(NSDictionary *)aDic noteName:(NSString *)aNoteName {
    NSArray *array = [aDic objectForKey:aNoteName];
    NSDictionary *dicInfo = [array objectAtIndex:0];
    if (dicInfo != nil) {
        [[WSAppData sharedManager].datas setObject:dicInfo forKey:aNoteName];
    }
}

#pragma mark - WSSelectListTableViewCellDelegate

- (void)selectListTableViewCell:(WSSelectListTableViewCell *)cell withSlectFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    
    UIViewController *viewController = [self nextPageWithFunsBean:bean withINdexStore:storeBean];
    
    [self gotoNextPageWithViewController:viewController withFuncsBean:bean withStoreBean:storeBean withAutoJump:YES];
}

#pragma mark WSSearchStoreViewControllerDelegate Method

- (void)viewController:(WSSearchStoreViewController *)viewController didSelectContent:(NSString *)content {
    self.ownSearchBar.searchBar.text = content;
    if (content.length == 0) {
        self.m_searchResult = nil;
    }else {
        self.m_searchResult = [NSMutableString stringWithString:content];
    }
    [self customQueryStartUpdata:nil];
}

// 如果是实时搜索门店列表，刷选条件筛选门店也需要实时收索
- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView  searchStoreWithCondition:(NSMutableDictionary *)conditions  rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance searchStoreType:(NSString *)storeType {
    
    self.conditions = conditions.copy;
    self.rangeConditions = rangeConditions;
    self.distance = distance;
    self.pageNumer = 0;
    [self.filterArray removeAllObjects];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    self.searchStoreType = storeType;
    WSAcvtBean * acvtBean = storeView.acvtBean;
    NSArray * acvtQstIdArray = [conditions allKeys];
    self.searchConditionDic = [[NSMutableDictionary alloc]initWithCapacity:acvtQstIdArray.count];

    if (acvtQstIdArray.count > 0) {
        self.isFilter = YES;
        for (NSString * acvtQstId in acvtQstIdArray) {
            WSAcvtBean_qst * qst = [acvtBean getQstBeanByAcvtQstID:acvtQstId];
            [self.searchConditionDic setObject:[conditions objectForKey:acvtQstId] forKey:qst.qstCod];
        }
    }
    else
    {
        self.isFilter = NO;
    }
    
    if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]){
        // YIHAIKERRY-3490 下载其他城市门店后无法搜索到 所以屏蔽判断本地是否有当前城市的逻辑
        //判断是否存在已下载数据,本地有数据就搜索本地，本地没有数据，就发请求
//        if ([[WSBaseStoreTable sharedTable] queryStoresWithSearchCode:self.currentCity]){
            [self refreshData];
//        } else {
//            [self customQueryStartUpdata:nil];
//        }
    } else {
        [self customQueryStartUpdata:nil];
    }

    self.searchConditionDic = nil;
    self.distance = 0.0f;
}
//YIHAIKERRY-4769
#pragma - mark - 修改筛选门店列表的参数    SFA-25608                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ：
//与安卓 统一逻辑： 在实时请求的门店列表中，查询数据时 isUseStoreFilter 为yes 则用标签匹配，为NO 则传入nil,不用问卷回显关系
- (NSString *)resetAcvtIdString {
    
    BOOL isUseStoreFilter = [WSBaseStoreDBService isUseStoreFilterQueryStoreWithAcvtId:self.acvtBeanForSearchStore.acvtId];
    if (isUseStoreFilter) {
        return self.acvtBeanForSearchStore.acvtId;
    }else {
        return @"";
    }
}


#pragma mark resetData

//判断SEQ是否服务器没有传递，是默认数据0
-(BOOL)isesqDefaulet:(NSArray *)array{
    if(!array)
        return NO;
    if(array.count==0)
        return NO;
    if(![array.firstObject isKindOfClass:[WSStoreBean class]]){
        return NO;
    }
    if(array.count==1){
        WSStoreBean * bean=array.firstObject;
        if([bean.seq isEqualToNumber:@0]){
            return YES;
        }else{
            return NO;
        }
    }
    if(array.count>1){
        WSStoreBean * bean_fir=array.firstObject;
        WSStoreBean * bean_sec=[array objectAtIndex:1];
        if([bean_fir.seq isEqualToNumber:@0] && [bean_sec.seq isEqualToNumber:@0]){
            return YES;
        }else{
            return NO;
        }
        
    }
    return NO;
}
/*
 *函数功能：按照SEQ排序
 */
-(NSArray*)seqSort:(NSArray*)inputArray{
    if(inputArray==nil)
        return nil;
    
    NSArray *resultArray = [inputArray sortedArrayUsingComparator:^NSComparisonResult(WSStoreBean * obj1, WSStoreBean * obj2) {
        
        NSNumber* id1=[NSNumber numberWithInt:[obj1.seq intValue]];
        NSNumber* id2=[NSNumber numberWithInt:[obj2.seq intValue]];
        NSComparisonResult result = [id1 compare:id2];
        return result == NSOrderedDescending; // 升序
        //return result == NSOrderedAscending;  // 降序
    }];
    
    return resultArray;

    
}

@end

@implementation WSCustomerQueryViewController (Tools)



@end
