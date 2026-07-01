//
//  WSSpecialAuditViewController.m
//  Zhongliang
//
//  Created by xiaotang.wang on 8/27/13.
//  Copyright (c) 2013 Winchannel. All rights reserved.
//

#import "WSSpecialAuditViewController.h"
#import "WinSFA.h"
#import "WinCoreDefine.h"
#import "WSLocationManager.h"
#import "WSLocationArray.h"
#import "WSAppData.h"
#import "WSLocationSelectViewController.h"
#import "WSRequestHelper.h"
#import "WSAcvtBean.h"
#import "WSAcvtViewController.h"
#import "WSPointInfo.h"
#import "WSBrandLevelArray.h"
#import "WSBrandAndPointListViewController.h"
#import "UIDevice+Addtional.h"



const float kWSAuditSearchBarLeftWidth = 80.0f;
const float kWSAuditSearchBarHeight = 44.0f;
NSString *const kWSAuditNotifyName = @"wsauditfetchpointinfo";

@interface WSSpecialAuditViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, WSLocationSelectViewControllerDelegate>

@property (nonatomic, strong)UITableView *iLocationsTableView;
@property (nonatomic, strong)UIButton *iLocationButton;
@property (nonatomic, strong)UISearchBar *iSearchBar;
@property (nonatomic, copy) NSString *iCurrentLocationString;
@property (nonatomic, assign)int iLocationSelectIndex;
@property (nonatomic, assign)BOOL iHasPointCitys;
@property (nonatomic, assign)CLLocationCoordinate2D iCurrentLocation;
@property (nonatomic, strong)UIAlertView *iAlertView;
@property (nonatomic, strong)NSMutableArray *iWSAcvtBeanList;
@property (nonatomic, assign)WSSpecialAuditWorkState iWorkState;

@property (nonatomic, assign)NSMutableArray *iPointInfoArray;
@property (nonatomic, strong)WSPointInfo *iCurrentPointInfo;
@property (nonatomic, copy)NSString *iTitleForButton;

//Make head view for table view
- (UIView *)makeHeadViewForTableView;

//定位
- (void)location;

@end

@implementation WSSpecialAuditViewController
@synthesize iLocationsTableView = _iLocationsTableView;
@synthesize iLocationButton = _iLocationButton;
@synthesize iSearchBar = _iSearchBar;
@synthesize iCurrentLocationString = _iCurrentLocationString;
@synthesize iLocationSelectIndex = _iLocationSelectIndex;
@synthesize iHasPointCitys = _iHasPointCitys;
@synthesize iCurrentLocation = _iCurrentLocation;
@synthesize iAlertView = _iAlertView;
@synthesize iWSAcvtBeanList = _iWSAcvtBeanList;
@synthesize iWorkState = _iWorkState;
@synthesize iPointInfoArray = _iPointInfoArray;
@synthesize iCurrentPointInfo = _iCurrentPointInfo;
@synthesize iTitleForButton = _iTitleForButton;

#pragma mark - init and view cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean
{
    self = [super initWithFuncs:aFuncsBean];
    if (self) {
        //Do something
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean withPointInfo:(WSPointInfo *)aInfo
{
    self = [super initWithFuncs:aFuncsBean];
    if (self != nil) {
        _iCurrentPointInfo = aInfo;
        _iWorkState = WSAuditFindAcvtListFromNetWorkState;
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    //add table view
    self.iLocationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.iLocationsTableView.backgroundColor = [UIColor clearColor];
    self.iLocationsTableView.backgroundView = nil;
    self.iLocationsTableView.dataSource = self;
    self.iLocationsTableView.delegate = self;
    [self.view addSubview:self.iLocationsTableView];
    
    self.iLocationSelectIndex = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    WSLocationArray *array =  [WSAppData getObjectbyKey:GEOPOINTCITYNAMES];
    if ([array.locationArray count] > 0) {
        self.iHasPointCitys = YES;
    }
    
    //Point info
    if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
        // Do nothing
    }else{
        WSBrandLevelArray *brandlevel = [WSAppData getObjectbyKey:GEOPOINTINFO];
        self.iPointInfoArray = brandlevel.iBrandLevelArray;
    }
    
    self.iLocationsTableView.tableHeaderView = [self makeHeadViewForTableView];
}

- (void)switchContent
{
    self.iWorkState = (self.iWorkState == WSAuditBrandLevelWorkState) ? WSAuditFindPointWorkState : WSAuditBrandLevelWorkState;
    NSString *contentInfo = (self.iWorkState == WSAuditBrandLevelWorkState) ?  NSLocalizedString(@"point_position", nil) : NSLocalizedString(@"pay_display_camera_brand", nil);
    self.ownParentViewController.navigationItem.rightBarButtonItem.title = contentInfo;
    [self.iLocationsTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.iLocationsTableView.tableHeaderView = [self makeHeadViewForTableView];
//    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
//    self.iLocationsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+44);
//    self.iLocationsTableView.tableHeaderView = [self makeHeadViewForTableView];
//    [self.iLocationsTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Remove notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWSAuditNotifyName object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    LogTrace();
    [super viewDidAppear:animated];
    LogInfo(@"\n[ LogInfo -  self.navigationController.toolbarHidden = YES; ]\n");
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)iWSAcvtBeanList
{
    if (_iWSAcvtBeanList == nil) {
        _iWSAcvtBeanList = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _iWSAcvtBeanList;
}

#pragma mark - private function
- (UIView *)makeHeadViewForTableView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, 44)];
    
    
    if ([[UIDevice currentDevice] systemVersionNotLowerThan:@"7.0"])
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight)];
        view.backgroundColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1.0];
        
        self.iLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.iLocationButton.frame = CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight);
        self.iLocationButton.showsTouchWhenHighlighted = YES;
        
        NSString *title = NSLocalizedString(@"beijing",nil);
        if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
            NSString *str = [self geoInfoForKey:GEONAME];
            if (str != nil && [str length] > 0) {
                title = str;
            }
            self.iTitleForButton = title;
        }
        title = (self.iTitleForButton == nil) ? title : self.iTitleForButton;
        [self.iLocationButton.titleLabel adjustsFontSizeToFitWidth];
        [self.iLocationButton setTitle:title forState:UIControlStateNormal];
        [self.iLocationButton addTarget:self action:@selector(locationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.iLocationButton];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"carat-open.png"]];
        imageView.frame = CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight);
        imageView.contentMode = UIViewContentModeRight;
        
        [view addSubview:imageView];
        [headerView addSubview:view];
#else
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight)];
        searchBar.placeholder = NSLocalizedString(@"query_label", nil);
        for (UIView *view in searchBar.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                [view removeFromSuperview];
                break;
            }
        }
        
        self.iLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.iLocationButton.frame = CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight);
        self.iLocationButton.showsTouchWhenHighlighted = YES;
        
        NSString *title = NSLocalizedString(@"beijing",nil);
        if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
            NSString *str = [self geoInfoForKey:GEONAME];
            if (str != nil && [str length] > 0) {
                title = str;
            }
            self.iTitleForButton = title;
        }
        title = (self.iTitleForButton == nil) ? title : self.iTitleForButton;
        [self.iLocationButton.titleLabel adjustsFontSizeToFitWidth];
        [self.iLocationButton setTitle:title forState:UIControlStateNormal];
        [self.iLocationButton addTarget:self action:@selector(locationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [searchBar addSubview:self.iLocationButton];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"carat-open.png"]];
        imageView.frame = CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight);
        imageView.contentMode = UIViewContentModeRight;
        
        [searchBar addSubview:imageView];
        [headerView addSubview:searchBar];
#endif
    }
    else
    {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight)];
        searchBar.placeholder = NSLocalizedString(@"query_label", nil);
        for (UIView *view in searchBar.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                [view removeFromSuperview];
                break;
            }
        }
        
        self.iLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.iLocationButton.frame = CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight);
        self.iLocationButton.showsTouchWhenHighlighted = YES;
        
        NSString *title = NSLocalizedString(@"beijing",nil);
        if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
            NSString *str = [self geoInfoForKey:GEONAME];
            if (str != nil && [str length] > 0) {
                title = str;
            }
            self.iTitleForButton = title;
        }
        title = (self.iTitleForButton == nil) ? title : self.iTitleForButton;
        [self.iLocationButton.titleLabel adjustsFontSizeToFitWidth];
        [self.iLocationButton setTitle:title forState:UIControlStateNormal];
        [self.iLocationButton addTarget:self action:@selector(locationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [searchBar addSubview:self.iLocationButton];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"carat-open.png"]];
        imageView.frame = CGRectMake(0, 0, kWSAuditSearchBarLeftWidth, kWSAuditSearchBarHeight);
        imageView.contentMode = UIViewContentModeRight;
        
        [searchBar addSubview:imageView];
        [headerView addSubview:searchBar];
    }
    _iCurrentLocationString = NSLocalizedString(@"beijing",nil);
    
    float xoffset = self.iHasPointCitys ? kWSAuditSearchBarLeftWidth : 0.0;
    float width = self.iHasPointCitys ?  self.view.bounds.size.height - kWSAuditSearchBarLeftWidth : self.view.bounds.size.height;
    self.iSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(xoffset, 0.0, width, kWSAuditSearchBarHeight)];
    self.iSearchBar.delegate = self;
    self.iSearchBar.text = @" ";
    self.iSearchBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.iSearchBar.placeholder = NSLocalizedString(@"query_label", nil);
    [headerView addSubview:self.iSearchBar];
    
    if (self.iHasPointCitys) {
//        self.iLocationSelectIndex = -1;
        
        if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
            NSString *str = [self geoInfoForKey:@"locationselectindex"];
            if (str != nil && [str length] > 0) {
                self.iLocationSelectIndex = [str intValue];
            }
        }
        
        [self location];
    }
    
    return headerView;
}

- (void)locationButtonClick:(id)aSender
{    
    WSLocationArray *locationArray = [WSAppData getObjectbyKey:GEOPOINTCITYNAMES];
    WSLocationSelectViewController *lsvc = [[WSLocationSelectViewController alloc] initWithCurrentLocation:self.iCurrentLocationString locationArray:locationArray selectIndex:self.iLocationSelectIndex];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:lsvc];
    lsvc.selectDelegate = self;
    [self presentViewController:navc  animated:YES completion:nil];
}


- (void)location {
    
    DDLogInfo(@"（wsspecialauditviewcontroller）: 使用通知方式获取定位回调");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
}

- (void)locationFinished:(NSNotification *)sender{
    
    DDLogInfo(@"（locationFinished）:通知回来了");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    self.iCurrentLocation = tmpLocationDescribe.location.coordinate;
    
    if (error) {
        LogError(@"获取位置失败,class:%@,error:%@",[self class], error);
    }
    
    if (CLLocationCoordinate2DIsValid(self.iCurrentLocation)) {
        [self resetLocation:tmpLocationDescribe.provinceName locality:tmpLocationDescribe.cityName subLocality:tmpLocationDescribe.subLocality];
    }
}

- (void)resetLocation:(NSString *)administrativeArea locality:(NSString *)locality subLocality:(NSString *)subLocality {
    
    /*  _locationSelectIndex = -1 代表选择定位信息
     *  >= 0 代表选择的 locationArray 的 index
     */
    
    if (locality) {
        self.iCurrentLocationString = locality;
    } else if (administrativeArea) {
        self.iCurrentLocationString = administrativeArea;
    }
    [[NSUserDefaults standardUserDefaults] setObject:_iCurrentLocationString forKey:kGlobalCityName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.iLocationSelectIndex == -1) {
        [self.iLocationButton setTitle:self.iCurrentLocationString forState:UIControlStateNormal];
    }
}
- (void)startFetchPointInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFinished:) name:(NSString *)kWSAuditNotifyName object:nil];

    NSMutableString *searchText = [[NSMutableString alloc] init];
    if (self.iSearchBar.text != nil) {
        [searchText appendString:self.iSearchBar.text];
    }
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    if (self.iHasPointCitys && [self.iSearchBar.text length] > 0) {
        if ([self.iSearchBar.text hasPrefix:@" "]) {
            NSString *temp = [self.iSearchBar.text substringFromIndex:1];
            searchText = [NSMutableString stringWithString:temp];
        }
    }
    
    [requestDic setObject:searchText forKey:CQ_KEYWORD];
    [requestDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    if (self.iHasPointCitys) {
        [requestDic setObject:[[NSNumber numberWithDouble:self.iCurrentLocation.latitude] stringValue] forKey:GPS_LAT];
        [requestDic setObject:[[NSNumber numberWithDouble:self.iCurrentLocation.longitude] stringValue] forKey:GPS_LON];
        
        if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
            NSString *lat = [self geoInfoForKey:GPS_LAT];
            NSString *lon = [self geoInfoForKey:GPS_LON];
            if (lat != nil && lon != nil) {
                [requestDic setObject:lat forKey:GPS_LAT];
                [requestDic setObject:lon forKey:GPS_LON];
            }
        }
        
        [requestDic setObject:self.iLocationButton.titleLabel.text forKey:GEONAME];
        if (self.iLocationSelectIndex != -1) {
            WSLocationArray *locationArray = [WSAppData getObjectbyKey:GEOPOINTCITYNAMES];
            WSLocation *location = [locationArray.locationArray objectAtIndex:self.iLocationSelectIndex];
            [requestDic setObject:location.cityCode forKey:@"cityCode"];
        }
        
    }
    [requestDic setObject:ACVTS_ZXJH_NODE_FOR_ZHONGLIANG forKey:@"objId"];
    
    if (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) {
        [requestDic setObject:self.iCurrentPointInfo.iPointId forKey:@"pointId"];
    }
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr postRequestData:requestDic notifyName:kWSAuditNotifyName];
    [self querying_messageTips];

}

- (void)fetchFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWSAuditNotifyName object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error && error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        NSString *info = [[sender userInfo] objectForKey:DATAS];
        NSDictionary *pointinfo = [info objectFromJSONString];
        NSArray *acvtList = [pointinfo objectForKey:@"acvt_zxjh"];
        if (acvtList && [acvtList count] > 0) {
            self.iWorkState = (self.iWorkState == WSAuditFindAcvtListFromNetWorkState) ? WSAuditFindAcvtListFromNetWorkState :WSAuditFindPointWorkState;
            if (self.iWorkState == WSAuditFindPointWorkState) {
                NSString *contentInfo = NSLocalizedString(@"pay_display_camera_brand", nil);
                self.ownParentViewController.navigationItem.rightBarButtonItem.title = contentInfo;
            }
            [self initAcvtBeanList:acvtList];
            [self.iLocationsTableView reloadData];
        }
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        if (self.ownParentViewController.navigationItem.rightBarButtonItem == Nil) {
            //switch
            NSString *contentInfo = (self.iWorkState == WSAuditBrandLevelWorkState) ?  NSLocalizedString(@"point_position", nil) : NSLocalizedString(@"pay_display_camera_brand", nil);
            UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithTitle:contentInfo style:UIBarButtonItemStylePlain target:self action:@selector(switchContent)];
            self.ownParentViewController.navigationItem.rightBarButtonItem = btnItem;
        }
    }
    NSLog(@"%@", sender);
}

- (void)initAcvtBeanList:(NSArray *)aDicArray
{
    [self.iWSAcvtBeanList removeAllObjects];
    for (NSDictionary *dic in aDicArray) {
        WSAcvtBean *acvt = [[WSAcvtBean alloc] initWithObject:dic];
        // 不需要过滤
//        if (acvt != nil && (acvt.typ != nil && [acvt.typ isEqualToString:self.currentFuncs.filter])) {
        [self.iWSAcvtBeanList addObject:acvt];
//        }
    }
}


#pragma mark - searchbar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
            [btn setTitle:CancelString  forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = @" ";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
    
    [self startFetchPointInfo];
    
}

#pragma mark - table view delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return (self.iWorkState == WSAuditBrandLevelWorkState) ? [self.iPointInfoArray count] : [self.iWSAcvtBeanList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kIdentify = @"pointcityinfo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentify];
    }
    
    NSString *text = nil;
    if (self.iWorkState == WSAuditBrandLevelWorkState) {
        WSPointInfo *pointinfo = [self.iPointInfoArray objectAtIndex:indexPath.row];
        text = pointinfo.iPointName;
    }else{
        WSAcvtBean *bean = [self.iWSAcvtBeanList objectAtIndex:indexPath.row];
        text = bean.acvtName;
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    if (self.iWorkState == WSAuditBrandLevelWorkState) {
        WSPointInfo *info = [self.iPointInfoArray objectAtIndex:indexPath.row];
        if (info.iPointInfoArray != nil) {
            vc = [[WSBrandAndPointListViewController alloc] initWithFuns:self.currentFuncs withArray:info.iPointInfoArray];
            vc.title = info.iPointName;
            [self saveGeoInfo];
        }
    }else{
        WSAcvtBean *bean = [self.iWSAcvtBeanList objectAtIndex:indexPath.row];
        vc = [[WSAcvtViewController alloc] initWithAcvt:bean Funcs:self.currentFuncs Store:nil];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - WSLocationSelectViewController delegate
- (void)locationSelectedAtIndex:(NSNumber *)index andArrat:(NSArray *)array
{
    if (index.intValue == -1) {
        [self.iLocationButton setTitle:self.iCurrentLocationString forState:UIControlStateNormal];
    } else {
        WSLocation *location = [array objectAtIndex:index.intValue];
        NSArray *areaArray = [location.city componentsSeparatedByString:@"-"];
        NSString *title = [areaArray lastObject];
        [self.iLocationButton setTitle:title forState:UIControlStateNormal];
        self.iTitleForButton = title;
    }
    self.iLocationSelectIndex = index.intValue;
    
    //remove user default
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@",
                     @"WSAudit",
                     self.currentFuncs.fc,
                     [WSAppData getObjectbyKey:APPDATA_EMPID]];
    [user removeObjectForKey:key];
    [user synchronize];
    
}


- (NSString *)geoInfoForKey:(NSString *)aKey
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@",
                     @"WSAudit",
                     self.currentFuncs.fc,
                     [WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSDictionary *dic = [user objectForKey:key];
    if (dic != nil) {
        NSString *info = [dic objectForKey:aKey];
        return info;
    }
    return nil;
}

- (void)saveGeoInfo
{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@",
                     @"WSAudit",
                     self.currentFuncs.fc,
                     [WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    if (self.iHasPointCitys) {
        NSMutableDictionary *dicForGeoinfo = [[NSMutableDictionary alloc] initWithCapacity:8];
        [dicForGeoinfo setObject:[[NSNumber numberWithDouble:self.iCurrentLocation.latitude] stringValue] forKey:GPS_LAT];
        [dicForGeoinfo setObject:[[NSNumber numberWithDouble:self.iCurrentLocation.longitude] stringValue] forKey:GPS_LON];
        [dicForGeoinfo setObject:self.iLocationButton.titleLabel.text forKey:GEONAME];
        [dicForGeoinfo setObject:[[NSNumber numberWithInteger:self.iLocationSelectIndex] stringValue] forKey:@"locationselectindex"];
        if (self.iLocationSelectIndex != -1) {
            WSLocationArray *locationArray = [WSAppData getObjectbyKey:GEOPOINTCITYNAMES];
            WSLocation *location = [locationArray.locationArray objectAtIndex:self.iLocationSelectIndex];
            [dicForGeoinfo setObject:location.cityCode forKey:@"cityCode"];
        }
        
        if (self.iSearchBar.text != nil && [self.iSearchBar.text length] > 0) {
            [dicForGeoinfo setObject:self.iSearchBar.text forKey:@"searchText"];
        }
        
        [user setObject:dicForGeoinfo forKey:key];
        
    }else{
        [user removeObjectForKey:key];
    }
    [user synchronize];
}

@end
