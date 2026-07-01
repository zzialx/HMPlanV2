//
//  WSRPMapViewController.m
//  WinSFA
//
//  Created by mac on 17/4/20.
//  Copyright © 2017年 WinChannel. All rights reserved.   
//

#import "WSRPMapViewController.h"
#import "PureLayout.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "WSSearchBar.h"
#import "WSResolveAddressManager.h"
#import "WSRPMapViewTablCell.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSNewTodayVisitAndAllStoreCell.h"
#import "WSRequestHelper.h"
#import "WSStoreDataProcessService.h"
#import "WSAllStoreProgressView.h"
#import "WSLocationManager.h"


#define CELL_HIGHT  44.0f

#define UPDATA_NOTIFY       @"selectStore_notify"


@interface WSRPMapViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MAMapViewDelegate>
@property(nonatomic,strong)UITableView * tabView;
@property (nonatomic , strong) MAMapView * mapSearchView;
@property (nonatomic , strong) NSMutableArray * tabDataArray;
@property (nonatomic , copy) NSString *cityAndDistrict;
@property (nonatomic , strong) UIButton  *bottomBtn;


@property(nonatomic,assign) NSInteger selectIndex;     // 选中的行
@property (nonatomic , strong) AMapPOI * selectPOI;   // 选中的店
@property (nonatomic , strong) AMapPOI * currentPOI;   // 当前位置

@property (nonatomic , strong) MAPointAnnotation *addAnnotation; // 已经添加的大头针

@property (nonatomic , copy) NSString *provinceCityDistricy; // 省市区

@property (nonatomic , strong) NSMutableArray * filterArray;

@property (nonatomic , strong) WSAllStoreProgressView * progressView;

@end

@implementation WSRPMapViewController
{
    NSTimer *_myTimer;
    float _sumTimer;
    NSString *_locationAddress;   // 定位地址
}
-(NSMutableArray *)tabDataArray{
    if (!_tabDataArray) {
        _tabDataArray = [[NSMutableArray alloc]init];
    }
    return _tabDataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"confirm", nil) style:UIBarButtonItemStylePlain target:self action:@selector(uploadData)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self addMapView];
    if (self.downByMap) {
        [self addBottomBtn];
        self.navigationItem.rightBarButtonItem = nil;
        self.title = self.currentFuncs.name;
    }
    if (self.storeTableArray.count>0)
    {
        [self addBottomSelectBtn];
        self.navigationItem.rightBarButtonItem = nil;
        self.title = self.currentFuncs.name;
    }
    [self addTableView];
    
 
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"加载中请稍后...", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    // 收索附近的数据
    [self addUserLocationAnnotation];
}
-(void)addMapView{
    
    _mapSearchView = [[MAMapView alloc] init];
    _mapSearchView.delegate = self;
    _mapSearchView.showsUserLocation = YES;
    _mapSearchView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:_mapSearchView];
    [_mapSearchView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, self.view.height * 0.5, 0)];
    // 收索框
    WSSearchBar * searchBar = [[WSSearchBar alloc]initWithFrame:CGRectZero isResetTextField:NO isResetBackgroundColor:YES];
    searchBar.backViewColor = [UIColor clearColor];
    if (self.searchPlaceholder.length > 0) {
        searchBar.searchBar.placeholder = NSLocalizedString(self.searchPlaceholder, nil);
    }else{
        searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    }
    
    searchBar.layer.cornerRadius = 16;
    searchBar.alpha = 0.8;
    searchBar.searchBar.delegate = self;
    [_mapSearchView addSubview:searchBar];
    [searchBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(GROUP_CELL_PADDING, GROUP_CELL_PADDING, 0, GROUP_CELL_PADDING) excludingEdge:ALEdgeBottom];
    [searchBar autoSetDimension:ALDimensionHeight toSize:CELL_HIGHT - 10];
    
    // 返回用户定位的位置
    UIButton * resetUserLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetUserLocation addTarget:self action:@selector(showUserLocationInMapCenter) forControlEvents:UIControlEventTouchUpInside];
    [resetUserLocation setImage:[UIImage imageForName:@"map_direction_locaton"] forState:UIControlStateNormal];
    [_mapSearchView addSubview:resetUserLocation];
    [resetUserLocation autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:MAIN_CELL_PADDING];
    [resetUserLocation autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:MAIN_CELL_PADDING];
    [resetUserLocation autoSetDimension:ALDimensionHeight toSize:CELL_HIGHT];
    [resetUserLocation autoSetDimension:ALDimensionWidth toSize:CELL_HIGHT];
    if (self.storeTableArray.count > 0) {
        [self addAllPOIViewToMapView];
    }
    
}
// 给当前位置设置主副标题
-(void)addUserLocationAnnotation{
    __weak typeof(self)weakSelf = self;
    CLLocationCoordinate2D myCoordinate = _mapSearchView.userLocation.coordinate;
    if (self.coordinate.latitude) {
        myCoordinate = self.coordinate;
    }
    [[WSResolveAddressManager shareInstance] startGetFormattedAddressWith:myCoordinate withBlock:^(AMapReGeocode *regeocode, NSError *error) {
        if (!error) {
            weakSelf.cityAndDistrict = [NSString stringWithFormat:@"%@%@",regeocode.addressComponent.city,regeocode.addressComponent.district];
            weakSelf.provinceCityDistricy = [NSString stringWithFormat:@"%@%@%@%@%@",regeocode.addressComponent.province?regeocode.addressComponent.province:regeocode.addressComponent.city, LUA_SEPARATOR, regeocode.addressComponent.city, LUA_SEPARATOR, regeocode.addressComponent.district];
            NSArray  *tempArray = [weakSelf sortArrayByDistance:regeocode.pois];
            AMapPOI * poi = [tempArray firstObject];
            poi.address = [NSString stringWithFormat:@"%@%@",weakSelf.cityAndDistrict,poi.address];
            _locationAddress = poi.address;
            weakSelf.currentPOI = poi;
            weakSelf.mapSearchView.userLocation.title = poi.name;
            weakSelf.mapSearchView.userLocation.subtitle = poi.address;
             if (!self.coordinate.latitude) {
                 [weakSelf.mapSearchView selectAnnotation:weakSelf.mapSearchView.userLocation animated:YES];
                 [weakSelf searchAroundAddressWithLocation:self.mapSearchView.userLocation.location.coordinate With:weakSelf.condition];
             }
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];

        }else {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"查询周边数据失败", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }

        
    }];
}

-(void)addTableView{
    _tabView = [[UITableView alloc]init];
    _tabView.delegate = self;
    _tabView.dataSource = self;
    [self.view addSubview:_tabView];
    CGFloat bottomMargin = 0;
    if (self.downByMap) {
        bottomMargin = self.bottomBtn.size.height;
    }
    if (self.storeTableArray.count>0)
    {
        bottomMargin = 45;
    }
    [_tabView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, bottomMargin, 0) excludingEdge:ALEdgeTop];
    [_tabView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_mapSearchView];
}

// 确定的数据
-(void)uploadData{
    if (self.confirmButtomClick) {
        self.confirmButtomClick(self.selectPOI?self.selectPOI:self.currentPOI ,self.provinceCityDistricy);
    }
 
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showUserLocationInMapCenter{
    self.selectPOI = nil;
    [self.mapSearchView selectAnnotation:self.mapSearchView.userLocation animated:YES];
    [self.tabView reloadData];
    [self.mapSearchView setCenterCoordinate:self.mapSearchView.userLocation.location.coordinate animated:YES];
}
- (void)backAction
{
    if (self.storeTableArray.count>0) {
        [[WSBaseStoreDBService shareInstance] deleteBaseStoreTable];
    }
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark --- 收索数据
-(void)searchAroundAddressWithLocation:(CLLocationCoordinate2D)coordinate2D With:(NSString *)condition{
    __weak typeof(self)weakSelf = self;

    if (condition.length > 0 && self.currentFuncs.opt.isCountry.length > 0) {
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        
        request.keywords = condition;
        [[WSResolveAddressManager shareInstance] startAMapPOIKeywordsSearchWith:request withBlock:^(NSArray *array, NSError *error) {
            if(array.count > 0)
            {
                AMapPOI * poi = [array firstObject];
                self.cityAndDistrict = [NSString stringWithFormat:@"%@%@",poi.city,poi.district];
            }
            [weakSelf searchBarTextDidEndWith:array andNSError:error];
            
        }];
    }
    else{
    
        AMapPOIAroundSearchRequest * request = [[AMapPOIAroundSearchRequest alloc]init];
        request.keywords = condition;
    // 按距离排序
        request.sortrule = 0;
    // 如果搜索的数据大于配置的最大显示条目
        request.offset = [self.maxItem integerValue];
        request.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
        request.radius = [self.range integerValue];
    
        [[WSResolveAddressManager shareInstance] startGetAroundSearchWith:request withBlock:^(NSArray *array, NSError *error) {
        
            [weakSelf searchBarTextDidEndWith:array andNSError:error];
       
        }];
    }
}
// 按距离排序
-(NSArray *)sortArrayByDistance:(NSArray *)array{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    return  [array sortedArrayUsingDescriptors:sortDescriptors];
}
- (void)searchBarTextDidEndWith:(NSArray*)array andNSError:(NSError*)error
{
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    if (!error) {
        self.selectPOI = nil;
        if (self.addAnnotation) {
            [self.mapSearchView removeAnnotation:self.addAnnotation];
            self.addAnnotation = nil;
        }
        [self.mapSearchView selectAnnotation:self.mapSearchView.userLocation animated:YES];
        [self.tabDataArray removeAllObjects];
        for (AMapPOI * poi in array) {
            poi.address = [NSString stringWithFormat:@"%@%@",self.cityAndDistrict,poi.address];
            if (poi.distance<1) {
                poi.distance = [self loadDistance:poi.location];

            }
            [self.tabDataArray addObject:poi];
        }
        
        //  YIHAIKERRY-2992
        // SFA 益海嘉里-传统渠道 iOS【门店拜访】地图模式选择门店时，搜索选定位置无门店时，页面无提示
        //YIHAIKERRY-3093
        //SFA 益海嘉里-传统渠道 -【ios】【门店拜访/门店列表】200家以上账号进入门店列表点击“地图选择地点”栏，进入附近门店搜索页有“没有门店可以选择”提示
        if (self.ViewCType == WSRPViewCTypeStore) {
            if (self.storeTableArray.count <= 0) {
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"no_store_can_choose", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeText];
            }
        }else{
            if (array.count <= 0) {
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"no_store_can_choose", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeText];
            }
        }
        [self.tabView reloadData];
    }else{
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"查询周边数据失败", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
#pragma mark ---  UISearchBarDelegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
   
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
           
                break;
            }
        }
        
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"搜索中请稍后...", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    [self searchAroundAddressWithLocation:self.mapSearchView.userLocation.location.coordinate With:self.condition];
}
// 点击收索，如果搜索值为空 搜索默认
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];

    if (searchBar.isFirstResponder) {
        [searchBar resignFirstResponder];
    }
    NSString * condition ;
    if (searchBar.text.length > 0) {
        condition = searchBar.text;
    }else{
        condition = self.condition;
    }
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"搜索中请稍后...", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    [self searchAroundAddressWithLocation:self.mapSearchView.userLocation.location.coordinate With:condition];
}

#pragma mark ---  UITableViewDelegate,UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.storeTableArray.count > 0) {
        return self.storeTableArray.count;
    }
    return self.tabDataArray.count;
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.storeTableArray.count > 0)
    {
        WSStoreBean *storeBean = self.storeTableArray[indexPath.row];
        static NSString *NewTableviewCellIdentifier = @"NewTableviewCellIdentifier";

        WSNewTodayVisitAndAllStoreCell * cell = [tableView dequeueReusableCellWithIdentifier:NewTableviewCellIdentifier];
        if (cell == nil)
        {
            cell = [[WSNewTodayVisitAndAllStoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewTableviewCellIdentifier cellWidth:tableView.width];
        }
//        cell.delegate = self;
        [cell setStore:storeBean withOpt:self.currentFuncs.opt prepareFuncsBean:nil prepareAcvtBean:nil];
        if([storeBean.isSelect isEqualToString:@"1"])
        {
            cell.storeSelect.image = [UIImage imageForName:@"selected_yes_radio_disabled@2x"];
        }
        else
        {
            cell.storeSelect.image = [UIImage imageForName:@"selected_no_radio@2x"];

        }
        storeBean.hasGetStateData = YES;
        return cell;
    }
    else
    {
        static NSString * reuserId = @"UITableViewCell";
        WSRPMapViewTablCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
        if (!cell) {
            cell = [[WSRPMapViewTablCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
        }
        cell.modelPOI = self.tabDataArray[indexPath.row];
    
        if (self.selectPOI && self.selectIndex == indexPath.row) {
            cell.isSelect = YES;
        }else{
            cell.isSelect = NO;
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.storeTableArray.count > 0)
    {
        WSStoreBean *storeBean = self.storeTableArray[indexPath.row];
//        WSNewTodayVisitAndAllStoreCell * cell = (WSNewTodayVisitAndAllStoreCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];

        if([storeBean.isSelect isEqualToString:@"0"])
        {
            storeBean.isSelect = @"1";
        }
        else
        {
            storeBean.isSelect = @"0";
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectIndex = indexPath.row;
        self.selectPOI = self.tabDataArray[indexPath.row];
        [self addSelectPOIViewToMapView];
        [self.tabView reloadData];
    }
}

// 设置cell的行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.storeTableArray.count > 0)
    {
        WSStoreBean *rowStore = [self.storeTableArray objectAtIndex:indexPath.row];

        return [WSNewTodayVisitAndAllStoreCell  heightForRowWithStore:rowStore cellWidth:self.tabView.width isHavePrepareButton:NO withOpt:self.currentFuncs.opt];
;
    }
    return [WSRPMapViewTablCell heightForcell:self.tabDataArray[indexPath.row]];
}

-(void)addSelectPOIViewToMapView{
    if (self.addAnnotation) {
        [_mapSearchView removeAnnotation:self.addAnnotation];
    }
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    self.addAnnotation = annotation;
    annotation.coordinate = CLLocationCoordinate2DMake(self.selectPOI.location.latitude, self.selectPOI.location.longitude);
    annotation.title  = self.selectPOI.name;
    annotation.subtitle = self.selectPOI.address;
    [_mapSearchView addAnnotation:annotation];
    [_mapSearchView selectAnnotation:annotation animated:YES];
}

-(void)addAllPOIViewToMapView{
    NSMutableArray *polArr = [NSMutableArray arrayWithCapacity:self.storeTableArray.count];
    for (WSStoreBean * storeBean in self.storeTableArray) {
        storeBean.isSelect = @"0";
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(storeBean.latitude, storeBean.longitude);
        annotation.title  = storeBean.name;
        annotation.subtitle = storeBean.addr;
        [polArr addObject:annotation];
    }
    [_mapSearchView addAnnotations:polArr];
    [_mapSearchView showAnnotations:polArr animated:YES];
}

- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout               = YES;
        annotationView.draggable                    = YES;
        annotationView.image = [UIImage imageNamed:@"search_point_icon"];
        return annotationView;
    }
    
    return nil;
}
//YIHAIKERRY-2637  donghong 点击大头针列表滚动到对应的门店
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    for ( NSInteger i = 0 ; i < self.storeTableArray.count ; i++ ) {
        WSStoreBean *storeBean = self.storeTableArray[i];
        if ([storeBean.name isEqualToString: view.annotation.title]) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_tabView scrollToRowAtIndexPath:scrollIndexPath
                                    atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
    }
}

- (void)addBottomBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    btn.frame = CGRectMake(0, self.view.size.height - 45 - 44, self.view.size.width, 45);
    
    [btn setTitle:@"搜索选定位置的附近门店" forState:UIControlStateNormal];
    
    [btn setTintColor:[UIColor whiteColor]];
    
    [btn addTarget:self action:@selector(bottomBtnDown) forControlEvents:UIControlEventTouchUpInside];
    
    [btn setBackgroundColor:[UIColor colorWithHexString:@"f73d15"]];
    
    [self.view addSubview:btn];
    
    self.bottomBtn = btn;
}
- (void)bottomBtnDown
{
    self.storeHttpService.location = _mapSearchView.centerCoordinate;
    if (self.selectPOI) {
        self.storeHttpService.location = CLLocationCoordinate2DMake(self.selectPOI.location.latitude, self.selectPOI.location.longitude);
        _locationAddress = self.selectPOI.address;
    }
    
    //YIHAIKERRY-2888
    CLLocationCoordinate2D tempLocation = self.storeHttpService.location;
    if([self.currentFuncs.opt.downByMap isEqualToString:@"1"] ||[self.currentFuncs.opt.downByMap isEqualToString:@"2"])
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

//    YIHAIKERRY-2639 网络请求加菊花 董宏
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

    __weak typeof(self)weakSelf = self;
    [self.storeHttpService getCustomerQueryStoreListDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
        if (dic && !error) {
            [weakSelf resetDataSources];
        }
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    }];
    
}
- (void)addBottomSelectBtn
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.size.height - 45 - 44, self.view.size.width, 45)];
    [self.view addSubview:bottomView];
    
    UIButton *oneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 45)];
    [oneButton setImage:[UIImage imageNamed:@"selected_no_radio"] forState:UIControlStateNormal];
    [oneButton setImage:[UIImage imageNamed:@"selected_yes_radio_disabled"] forState:UIControlStateSelected];
    [oneButton setTitle:@"全选" forState:UIControlStateNormal];
    oneButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [oneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [oneButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [oneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0,0)];
    oneButton.backgroundColor = [UIColor whiteColor];
    [oneButton addTarget:self action:@selector(oneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:oneButton];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    btn.frame = CGRectMake(self.view.size.width-92,0,92, 45);
    
    [btn setTitle:@"下载" forState:UIControlStateNormal];
    
    [btn setTintColor:[UIColor whiteColor]];
    
    [btn addTarget:self action:@selector(bottomSelectBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [btn setBackgroundColor:[UIColor colorWithHexString:@"f73d15"]];
    
    [bottomView addSubview:btn];
    
    
}
- (void)oneButtonAction:(UIButton*)btn
{
    btn.selected = !btn.selected;
    NSString *str = @"0";
    if (btn.selected) {
        str = @"1";
    }
    for (WSStoreBean * storeBean in self.storeTableArray) {
        storeBean.isSelect = str;
    }
    
    [self.tabView reloadData];
    
}
- (void)bottomSelectBtn
{
    NSMutableString *storeIds = [NSMutableString stringWithCapacity:0];
    self.filterArray = [NSMutableArray arrayWithCapacity:self.storeTableArray.count];
    //顺序遍历
    [self.storeTableArray enumerateObjectsUsingBlock:^(WSStoreBean *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.isSelect isEqualToString:@"1"])
        {
            [self.filterArray addObject:obj];
            
            if (storeIds.length>0) {
                [storeIds appendFormat:@",%@",obj.Id];

            }
            else
            {
                [storeIds appendFormat:@"%@", obj.Id];
            }
        }
      
    }];
    
    
    if (storeIds.length<1)
    {
        NSString *cancel = NSLocalizedString(@"cancel_label", nil);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:@"请您最少选择一家门店"];
        [alert setCancelButtonWithTitle:cancel block:nil];
        [alert show];
        
        return;
    }
    self.progressView =  [[WSAllStoreProgressView alloc] initWithSelect:self.filterArray.count];
    
    [self.progressView  showXLAlertView];
    
    _myTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES]; //< 需要加入手动RunLoop，需要注意的是在NSTimer工作期间self是被强引用的
    [[NSRunLoop currentRunLoop] addTimer:_myTimer forMode:NSRunLoopCommonModes]; //< 使用NSRunLoopCommonModes才能保证RunLoop切换模式时，NSTimer能正常工作。
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr appUpdataManagerInfo:nil StoreIds:storeIds subempId:nil withObjId:[self getObjIDToStoreInfo] notifyName:UPDATA_NOTIFY styp:nil];
    
}
-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATA_NOTIFY
                                                  object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        [self closeProgressView];
        NSString *tmpString = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        
        NSString *objId = [self getObjIDToStoreInfo];
        
        NSObject *tmpObject = uploadState[objId];
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
//            storeDicInfo = [(NSArray *)tmpObject firstObject];
//            if ([(NSArray *)tmpObject count]) {
                [self uploadStoreInfo:(NSArray*)tmpObject];
//                return;
//            }
        }
       
    }
}

- (void)uploadStoreInfo:(NSArray*)storeInfoArr
{
//    NSInteger sum = 0;
    for (NSDictionary *dic in storeInfoArr) {
        for (NSInteger i = 0 ; i < self.storeTableArray.count ; i++) {
            WSStoreBean *storeBean =  self.storeTableArray[i];
            if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]] isEqualToString:storeBean.Id]) {
                [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:dic];
                NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
                [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:storeBean.Id];
                break;
            }
        }
//        self.progressView.progress = ++sum;
    }
    [self closeProgressView];
   
    [[WSBaseStoreDBService shareInstance] deleteBaseStoreTable];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)closeProgressView
{
    [_myTimer invalidate];
    _myTimer = nil;
    [self.progressView removeFromSuperview];
    self.progressView = nil;

}
- (NSString *)getObjIDToStoreInfo
{
    WSFuncsBean *funcsBean = self.currentFuncs;
    if (funcsBean.funcsArray && funcsBean.funcsArray.count == 1)
    {
        WSFuncsBean *tempFuncsBean = [funcsBean.funcsArray firstObject];
        return ((tempFuncsBean.filter.length > 0) ? tempFuncsBean.filter : ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME);
    }
    else
        return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
}
-(void)resetDataSources{
    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = subEmpId?:currenteEmpId;
    NSString *funCode = self.currentFuncs.fc;
    
    NSString *stringKey = self.storeHttpService.objID;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    
    NSString *search_ObjCode_Code = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];
    
    BOOL isSearchable = ([self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote] ||
                         [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto]);
 
    NSArray *searchedStore =[[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:search_ObjCode_Code search_objId:stringKey isSearchable:isSearchable storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal acvtId:nil selectedQstValues:nil rangeConditions:nil distance:0 pageNumber:0 distanceSort:self.currentFuncs.opt.distancesSort otherDataDic:nil parentStoreFc:self.currentFuncs.opt.parentStoreFc];
    
    if (searchedStore.count <= 0) {//如果搜索选定位置的附近门店 数组为空，则不继续跳转，直接弹出提示框“没有门店可以选择”
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"no_store_can_choose", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeText];
        });
        return;
        
    }
    
    WSRPMapViewController * rpMap = [[WSRPMapViewController alloc]init];
    rpMap.storeTableArray = [NSMutableArray arrayWithArray:searchedStore];
    rpMap.coordinate = CLLocationCoordinate2DMake(self.selectPOI.location.latitude, self.selectPOI.location.longitude);
    rpMap.currentFuncs = self.currentFuncs;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_locationAddress forKey:LOCATION_ADDRESS];
    [userDefaults synchronize];

    [self.navigationController pushViewController:rpMap animated:YES];

}
- (CLLocationDistance)loadDistance:(AMapGeoPoint*)location
{
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:_mapSearchView.userLocation.coordinate.latitude longitude:_mapSearchView.userLocation.coordinate.longitude]
                           ;
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    return [location1 distanceFromLocation:location2];
}
//虚拟进度条 董宏  YIHAIKERRY-2585 查表太快只能用虚拟的
-(void)timerFired:(NSTimer *)timer {
    if (self.filterArray.count > 10) {
        _sumTimer += 2;
    }
    else if (self.filterArray.count > 5)
    {
        _sumTimer += 1;
    }
    else if (self.filterArray.count > 3)
    {
        _sumTimer += 0.5;
    }
    else
    {
        _sumTimer += 0.4;
    }
    self.progressView.progress = self.filterArray.count > _sumTimer ? _sumTimer : self.filterArray.count-1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
