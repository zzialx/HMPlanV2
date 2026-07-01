//
//  StoreSearchFromNetViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSStoreSearchFromNetViewController.h"
#import "WSFuncsBean.h"
#import "AppUpload.h"
#import "WSStoreBean.h"
#import "Wch_m_inout_storeTable.h"
//TODO:对上层依赖，需要重构
//#import "MyModifyStoreInfoViewController.h"
#import "WSStoreAcvtDisBean.h"
#import "WSStoreAcvtDisArray.h"
#import "WSStoreInfoBeanArray.h"
#import "WSWorkFlowViewController.h"
#import "WSFuncsBeanArray.h"
#import "WSAddNewStoreViewController.h"
#import "WCOptionalSource.h"

#define FETCHINGSTOREINFO_NOTIFY @"fetchingstoreinfo_notify"
#define UPDATESTOREINFO_NOTIFY @"storefetchingupdateinfo_notify"
//#define STOREINFOS          @"storeInfo"

@interface WSStoreSearchFromNetViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong)UITableView *iResultTableView;
@property (nonatomic, strong)UISearchBar *iSearchBar; 
@property (nonatomic, strong)UIAlertView *iAlert;
@property (nonatomic, strong)NSMutableArray *iSearchResult;
@property (nonatomic, strong)NSString *iFilter;
@property (nonatomic, strong)WSFuncsBean *iCurrentBean;
@property (nonatomic, strong)WSStoreBean *iCurrentStore;

- (void)fetchingtStoreInfoFromNet:(NSString *)aStoreNameFilter;
- (void)finshFetchingStoreInfoFromNet:(id)sender;
- (void)startUpdata:(WSStoreBean*)store;
- (void)finishRequest:(id)sender;
- (void)goNextWorkView;
- (WSFuncsBean*)getSubMenu:(NSString*)subMenu;

@end

@implementation WSStoreSearchFromNetViewController
@synthesize iSearchBar = _iSearchBar;
@synthesize iSearchResult = _iSearchResult;
@synthesize iFilter = _iFilter;
@synthesize iResultTableView = _iResultTableView;
@synthesize iCurrentBean = _iCurrentBean;
@synthesize iAlert = _iAlert;
@synthesize iCurrentStore = _iCurrentStore;
@synthesize shouldAddFilters = _shouldAddFilters;

#pragma mark - init & dealloc

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Do something
        return  self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)aFuns andFilter:(NSString *)aFilter
{
    if (!aFuns || !aFilter ) 
        return nil;
    
    self = [super init];
    if (self) {
        self.iCurrentBean = aFuns;
        self.iFilter = aFilter;
        return self;
    }
    return nil;
}

- (NSMutableArray *)iSearchResult
{
    if (!_iSearchResult) 
    {
        _iSearchResult = [[NSMutableArray alloc] init];
    }
    return _iSearchResult;
}


#pragma mark - View lifecycle

- (void)loadView
{
    WSFuncsBean *fb = nil;
    if ([self.iCurrentBean.funcsArray count] > 0)
    {
        fb = [self.iCurrentBean.funcsArray objectAtIndex:0];
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:fb.fv];
    }
    // Crate view
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    self.view = view;
    
    // Table view
    CGRect frame = CGRectMake(0, 0, 320, 416);
    UITableView *tv = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.iResultTableView = tv;
    self.iResultTableView.delegate = self;
    self.iResultTableView.dataSource = self;
    self.iResultTableView.backgroundColor = [UIColor whiteColor];
    self.iResultTableView.backgroundView = nil;
    [self.view addSubview:self.iResultTableView];
    
    // Search bar
    UISearchBar *bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    bar.delegate = self;
    self.iSearchBar = bar;
    self.iResultTableView.tableHeaderView = self.iSearchBar;
    [self.view addSubview:self.iSearchBar];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *addFilter = [self.shouldAddFilters objectForKey:self.iFilter];
    if (addFilter)
    {
        NSString *AddString = NSLocalizedString(@"添加",nil);
        UIBarButtonItem* button = [[UIBarButtonItem alloc]
                                   initWithTitle:AddString
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(addNewStore)];
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.iSearchResult = nil;
    self.iFilter = nil;
    self.iSearchBar = nil;
    self.iResultTableView = nil;
    self.iCurrentBean = nil;   
    self.iCurrentStore = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - private functions
- (void)fetchingtStoreInfoFromNet:(NSString *)aStoreNameFilter
{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(finshFetchingStoreInfoFromNet:) name:FETCHINGSTOREINFO_NOTIFY object:nil];
    
    AppUpload *upload = [AppUpload shareInstance];
    [upload appFetchStoreInfoWith:aStoreNameFilter andFilter:self.iFilter notifyName:FETCHINGSTOREINFO_NOTIFY];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    NSString *tmpString = NSLocalizedString(@"正在获取信息，请稍候...",nil);
    self.iAlert = [[UIAlertView alloc] initWithTitle:tmpString 
                                       message:nil
                                      delegate:self 
                             cancelButtonTitle:nil 
                             otherButtonTitles:nil, nil] ;
    
    aiv.frame =  CGRectMake(139.0f - 18.0f, 60.0f, 37.0f, 37.0f);
    [self.iAlert addSubview:aiv];
    [self.iAlert show];
}

- (void)finshFetchingStoreInfoFromNet:(id)sender
{
    // Remove the notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:FETCHINGSTOREINFO_NOTIFY object:nil];
    
    [self.iAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.iAlert = nil;
    
    NSLog(@"%@", [sender userInfo]);
    NSString *datas = [[sender userInfo] objectForKey:DATAS];
    NSLog(@"%@", datas);
    //Fetch flag
    NSNumber *flag = [[datas JSONValue] objectForKey:@"flag"];
    if (flag && [flag integerValue] == 1) {
        
//        NSString *empId = [AppData getObjectbyKey:APPDATA_EMPID];
//        NSArray *serverRequire = [AppData getObjectbyKey:SERVERREQUIRE];
//        NSArray *empOrdIds = [(NSDictionary *)[serverRequire objectAtIndex:0] objectForKey:@"empOrgIds"];
//        NSString *orgId = [(NSDictionary *)[empOrdIds objectAtIndex:0] objectForKey:@"orgId"];
        
        [self.iSearchResult removeAllObjects];
        [self.iResultTableView reloadData];
        NSArray *array = [[datas JSONValue] objectForKey:@"Executiveinfo"];
        for (NSDictionary *dic in array) {
            NSString *storename = [dic objectForKey:@"name"];
            if (!storename || [storename isKindOfClass:[NSNull class]] ) {
                continue;
            }
            
            NSNumber *storeid = [dic objectForKey:@"id"];
            WSStoreBean *store = [[WSStoreBean alloc] init ];
            store.name = storename;
            store.Id = [storeid stringValue];
            store.styp = self.iFilter;
//            store.sv = [NSString stringWithFormat:@"%@,%@", empId,orgId];
            [self.iSearchResult addObject:store];
        }
        [self.iResultTableView reloadData];
    }else {
        NSString *localstring = NSLocalizedString(@"发生错误", nil);
        iToast *toast = [iToast makeText:localstring];
        [toast setDuration:iToastDurationNormal];
        [toast setGravity:iToastGravityBottom];
        [toast show];
    }
}

- (void)setAccessFlag:(UITableViewCell*)cell Store:(WSStoreBean*)store
{
    if ([[Wch_m_inout_storeTable sharedm_inout_store] isEnterStore:store]) {
        cell.imageView.image = nil;
    }  
    else
    {
        UIImage* image = [UIImage imageNamed:@"point.png"];
        cell.imageView.image = image;
    }
}

//-(BOOL)anyStoreHasNotLeave:(StoreBean*)aStore
//{
//    wch_inoutStoreObjects* l_store = [[Wch_m_inout_storeTable sharedm_inout_store] anyStorehaveNotLeave];
//    
//    if( l_store.store_id != nil&&![l_store.store_id isEqualToString:aStore.Id]) 
//    {
//        NSString *LeaveString = NSLocalizedString(@"还没有离店",nil);
//        iToast *toast = [iToast makeText:[NSString stringWithFormat:@"%@%@",l_store.memo1,LeaveString]] ;
//        [toast setDuration:iToastDurationNormal];
//        [toast setGravity:iToastGravityBottom];
//        [toast show];
//        return NO;
//    }
//    return YES;
//}

- (void)startUpdata:(WSStoreBean*)store
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATESTOREINFO_NOTIFY 
                                               object:nil];    
    AppUpload *uploadMgr = [AppUpload shareInstance];
    [uploadMgr appUpdataOutPlanInfo:store 
                         notifyName:UPDATESTOREINFO_NOTIFY];
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    NSString *tmpString = NSLocalizedString(@"正在获取信息，请稍候...",nil);
    self.iAlert = [[UIAlertView alloc] initWithTitle:tmpString 
                                       message:nil
                                      delegate:self 
                             cancelButtonTitle:nil 
                             otherButtonTitles:nil, nil] ;
    
    aiv.frame =  CGRectMake(139.0f - 18.0f, 60.0f, 37.0f, 37.0f);
    [self.iAlert addSubview:aiv];
    [self.iAlert show];
}

- (void)finishRequest:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UPDATESTOREINFO_NOTIFY 
                                                  object:nil];
    
    [self.iAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.iAlert = nil;
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"网络无法连接，请检查网络",nil);
        iToast *toast = [iToast makeText:tmpString] ;
        [toast setDuration:iToastDurationNormal];
        [toast setGravity:iToastGravityBottom];
        [toast show];
        return;
    }else{
        
        NSDictionary *uploadState = [info JSONValue];
        NSArray *allplans = [uploadState objectForKey:@"allplanstoreotherinfoontime"];
        if (!allplans || [allplans count] == 0)
        {
//            if ([self.iFilter isEqualToString:@"compstore"])
//            {
                [self performSelector:@selector(goNextWorkView)];
//            }
            return;
        }
        
        if(self.iCurrentStore != nil && allplans)
            [self.iCurrentStore reSetStore:uploadState Key:@"allplanstoreotherinfoontime"];
        
        // 处理回显节点数据内容
        [self dealWithStoreDictdis:uploadState];
        // 处理巡访提醒节点
        [self dealWithStoreInfo:uploadState];
        
        NSString *tmpString = NSLocalizedString(@"更新完成",nil);
        iToast *toast = [iToast makeText:tmpString] ;
        [toast setDuration:iToastDurationNormal];
        [toast setGravity:iToastGravityBottom];
        [toast show];
        [self performSelector:@selector(goNextWorkView)];
    }    
}


- (void)addNewStore
{
    WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
    NSString *addFilterPath = [self.shouldAddFilters objectForKey:self.iFilter];
    WSFuncsBean *l_fb = [fba getFuncsBeanFromSubFC:addFilterPath];
    
    WSAddNewStoreViewController *l_newStoreVC = [[WSAddNewStoreViewController alloc] initWithFuncs:l_fb ];
//    l_newStoreVC.delegate = self;
    
    [self.navigationController pushViewController:l_newStoreVC animated:YES];
    
}


- (void)dealWithStoreDictdis:(NSDictionary *)uploadState
{
    NSArray *arr = [uploadState objectForKey:@"allplanstoreotherinfoontime"];
    NSDictionary *dic = [arr objectAtIndex:0];
    
    NSArray *acvtdisArray = [dic objectForKey:@"storeacvtdis"];
    for (NSDictionary *item in acvtdisArray) 
    {     
        WSStoreAcvtDisBean *sb = [[WSStoreAcvtDisBean alloc]initWithObject:item];
        [self.iCurrentStore.acvtDisArray addObject:sb];
    }
    
    NSArray *dictdisArray = [dic objectForKey:@"storedictdis"];
    NSMutableArray *array = [WSAppData getObjectbyKey:STOREDICTDIS];
    NSArray *tempArr = [array copy];
    if (array == nil)
    {
        array = [[NSMutableArray alloc] init];
        [WSAppData putObject:array forKey:STOREDICTDIS];
    }
    else
    {
        for (NSArray *item in tempArr) 
        {
            if ([[item objectAtIndex:0] isEqualToString:self.iCurrentStore.Id]) 
            {
                [array removeObject:item];
            }
        }
    }
    for (NSDictionary *item in dictdisArray) 
    {
        NSString *p = [item objectForKey:@"p"];
        NSArray *pArray = [p componentsSeparatedByString:@","];
        [array addObject:pArray];
    }
}


- (void)dealWithStoreInfo:(NSDictionary *)uploadState
{
    NSArray *tempArray = [uploadState objectForKey:@"allplanstoreotherinfoontime"];
    NSDictionary *object = [tempArray objectAtIndex:0];
    
    WSStoreInfoBeanArray *loginStoreInfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
    NSMutableArray* l_dataArray = [[NSMutableArray alloc] init];
    for(WSStoreInfoBean* f_storeInfo in loginStoreInfoBeans.storeinfoArray)
    {
        if(![f_storeInfo.storeId isEqualToString:self.iCurrentStore.Id] && ![f_storeInfo.typ isEqualToString:self.iCurrentBean.filter])
        {
            [l_dataArray addObject:f_storeInfo];
        }
    }
    
    WSStoreInfoBeanArray *storeinfoBeans = [[WSStoreInfoBeanArray alloc] initWithObject:object];
    [storeinfoBeans.storeinfoArray addObjectsFromArray:l_dataArray];
    [WSAppData putObject:storeinfoBeans forKey:STOREINFOS];
}


- (void)goNextWorkView
{
    //以下code因submenu而改
    if ([self.iCurrentBean.funcsArray count]<1) {
        return;
    }
    
    //查询门店
    WSFuncsBean* nextfb = [self.iCurrentBean.funcsArray objectAtIndex:0];
    if (!nextfb || !nextfb.funcsArray || [nextfb.funcsArray count] == 0) {
        return;
    }
    
    //结果清单
    nextfb = [nextfb.funcsArray objectAtIndex:0];
    if (!nextfb || !nextfb.funcsArray || [nextfb.funcsArray count] == 0) {
        return;
    }    
    
    WSWorkFlowViewController* wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:nextfb Store:self.iCurrentStore];
    // Add UIViewController title
    wfvc.title = self.iCurrentStore.name;
    
    [self.navigationController pushViewController:wfvc animated:YES];
}

- (WSFuncsBean*)getSubMenu:(NSString*)subMenu
{
    if(subMenu == nil)
        return nil;
    
    WSFuncsBeanArray* fbArray = [WSAppData getObjectbyKey:FUNCS];
    if (fbArray ==nil) {
        return nil;
    }
    WSFuncsBean* resultFB =[fbArray getFuncsBeanFromSubFC:subMenu];
    return resultFB;
}

#pragma mark - UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iSearchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // reuseIdentifier
    static NSString *tvIdentifier = @"com.winchannel.storesearchfromnet";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tvIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tvIdentifier];
    }
    
    WSStoreBean *store = [self.iSearchResult objectAtIndex:indexPath.row];
    [self setAccessFlag:cell Store:store];
    cell.textLabel.text = store.name;
    if ([self.iFilter isEqualToString:@"expansion"])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

#pragma mark - UITableView delegate
//TODO:对上层依赖，需要重构
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    StoreBean* l_store = [self.iSearchResult objectAtIndex:indexPath.row];
//    if ([self.iFilter isEqualToString:@"expansion"])
//    {
//        MyModifyStoreInfoViewController *storeInfo = [[MyModifyStoreInfoViewController alloc] 
//                                                      initWithStoreInfo:l_store 
//                                                      filter:self.iFilter];
//        NSString *StoreInforString = NSLocalizedString(@"门店信息查询",nil);
//        storeInfo.title = StoreInforString;
//        [self.navigationController pushViewController:storeInfo animated:YES];
//        [storeInfo release]; 
//        return;
//    }
//    
//    if (![self anyStoreHasNotLeave:l_store]) return;
//    self.iCurrentStore = l_store;
//    [self startUpdata:l_store];
//}
//
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
//{
//    StoreBean* l_store = [self.iSearchResult objectAtIndex:indexPath.row];
//    MyModifyStoreInfoViewController *storeInfo = [[MyModifyStoreInfoViewController alloc] initWithStoreInfo:l_store filter:self.iFilter];
//    NSString *StoreInforString = NSLocalizedString(@"门店信息查询",nil);
//    storeInfo.title = StoreInforString;
//    
//    [self.navigationController pushViewController:storeInfo animated:YES];
//    [storeInfo release];    
//}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    for(id btn in [searchBar subviews]) {
        if ([btn isKindOfClass:[UIButton class]]) {
            UIButton *btncancle = (UIButton *)btn;
            NSString *cancelString = NSLocalizedString(@"Cancle", nil);
            [btncancle setTitle:cancelString forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar 
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.iResultTableView.allowsSelection = YES;
    self.iResultTableView.scrollEnabled = YES;
    [self.iResultTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    NSString *name = searchBar.text;
    [self fetchingtStoreInfoFromNet:name];
}

@end
