//
//  WSNewRouteViewController.m
//  WinSFA
//
//  Created by admin on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSNewRouteViewController.h"
#import "MJRefresh.h"
#import "WSStoreRouteDataModel.h"
#import "WSNewRouteTableViewCell.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSRequestTools.h"
#import "WSRouteStoreViewModel.h"
#import "WSNewRouteModel.h"
#import "WinJSBridgeViewController.h"
#import "WSReportFormController.h"
#import "WSRouteStoreListViewController.h"
#import "WSFuncsBean.h"
#import "WSFuncsBeanArray.h"
#import "WSStoreRouteViewHeaderView.h"
#import "WSTskfRouteTjModel.h"

#define STORE_LIST_FV       @"FV_NewStore_List"

static CGFloat const kStoreRouteCellHeight    = 100;
static CGFloat const kStoreRouteHeaderHeight    = 40;
static NSString * const kStoreRouteCellId     = @"StoreRouteCellId";
static NSString * const kStoreRouteHeaderId   = @"StoreRouteHeaderId";

@interface WSNewRouteViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) WSStoreRouteDataModel *routeModel;

@property (nonatomic,strong) NSString *routeId;

@property (nonatomic, strong)NSIndexPath * selectIndexPah;///<选中的路线

@property (nonatomic, strong)WSRouteStoreViewModel * viewModel;

@property (nonatomic, strong)NSArray * routeList;

///表头view
@property (nonatomic, strong)WSStoreRouteViewHeaderView *headerView;

@property (nonatomic, strong)WSTskfRouteTjInfoModel * headModel;

///搜索框
@property (nonatomic, strong)WSSearchBar * searchBar;

@property (nonatomic, strong) UIBarButtonItem *locationButton;


@end

@implementation WSNewRouteViewController

#pragma mark - # ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
    __weak typeof(self) wself = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself loadRoute];
    }];
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadRoute];
    [self getNavigationItem].titleView = self.searchBar;
    [self addLocationBarButtonItem];
    [self setBarButtonTitle];
}
#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    LogInfo(@"路线搜索输入--->%@",searchBar.text);
    self.viewModel.keyWord = searchBar.text;
    [self loadRoute];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    LogInfo(@"路线搜索输入--->%@",searchBar.text);
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    self.viewModel.keyWord = searchBar.text;
    [self loadRoute];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

#pragma mark - # UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSNewRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoreRouteCellId forIndexPath:indexPath];
    if(cell==nil){
        cell = [[WSNewRouteTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStoreRouteCellId];
    }
    cell.routeModel = self.routeList[indexPath.row];
    
//    @weakify_self;
//    [cell setClicikAction:^(NSString *date, RouteViewBtnType clickType) {
//        
//        @strongify_self;
//        if (clickType == RouteViewBtnType_Edit) {
//            
//            WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
//            vc.externalOpenUrl = self.currentFuncs.opt.jumpUrlLink;
//            vc.externalInfoDic = @{Win_JSBridge_URL_Replacing_VisitDate_Mark : date};
//            [self gotToController:vc];
//            
//            return;
//        }if(clickType == RouteViewBtnType_Search){
//            WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:self.currentFuncs.opt.routeSearchurl]];
//            rfvc.title = @"路线查询";
//            [self gotToController:rfvc];
//            return;
//        }
//    }];
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    @weakify_self;
//    void (^callBack)(RouteViewBtnType clickType) = ^(RouteViewBtnType clickType){
//        @strongify_self;
//        WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:self.currentFuncs.opt.routeSearchurl]];
//        rfvc.title = @"路线查询";
//        [self gotToController:rfvc];
//    };
    WSStoreRouteViewHeaderView *headerView = (WSStoreRouteViewHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kStoreRouteHeaderId];
//    [headerView setRouteHeadClickAction:callBack];
//    if(self.headModel){
//            [headerView settWithTotal:self.headModel.totalNo.integerValue execNum:self.headModel.zxNo.integerValue unExecNum:0];
//        }else{
//            [headerView settWithTotal:0 execNum:0 unExecNum:0];
//        }    headerView.isShowNotPlan = NO;
    self.headerView = headerView;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kStoreRouteHeaderHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WSNewRouteModel * model = self.routeList[indexPath.row];
    NSString * date = model.docDate;
    if(date==nil)return;
    if(date){
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"routeId"];
    }
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *fb = [funcsArray getFuncsBeanWithFV:STORE_LIST_FV];
    if (!fb) { //老逻辑
        fb = [funcsArray getFuncsBeanWithFV:STORE_LIST_FV];
        if (!fb){
            fb = [funcsArray getHideFuncsBeanWithFV:STORE_LIST_FV];
        }
    }
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    if([vc isKindOfClass:[WSRouteStoreListViewController class]]){
        WSRouteStoreListViewController*  routeStoreListVC = (WSRouteStoreListViewController*)vc;
        routeStoreListVC.docDate = date;
        routeStoreListVC.isRequestStoreList = YES;
        [self gotToController:routeStoreListVC];
    }
}
#pragma mark - # Request Data
- (void)loadRoute{
    [self querying_messageTips];
    @weakify_self;
    [self.viewModel resuetRouteListSucess:^(NSArray * _Nonnull list) {
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        @strongify_self;
        self.routeList = list;
        [self.tableView reloadData];
        } failure:^(NSString * _Nonnull tips) {
            [self.tableView.mj_header endRefreshing];
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            [MBProgressHUD showHUDAddedTo:self.view withText:tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }];
    
    
    [self.viewModel getRouteStatisticsInfoSucess:^(NSArray<NSObject *> * _Nonnull list) {
        //@strongify_self;
        WSTskfRouteTjInfoModel * model =  (WSTskfRouteTjInfoModel*)list.firstObject;
        if(model){
            //self.headModel = model;
            //[self.headerView settWithTotal:model.totalNo.integerValue execNum:model.zxNo.integerValue unExecNum:0];
        }
        } failure:^(NSString * _Nonnull tips) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            [MBProgressHUD showHUDAddedTo:self.view withText:tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
    }];
    
}
- (void)gotToController:(WCBaseViewController *)wfvc {
    LogInfo(@"Going to class WSWorkFlowViewController");
    wfvc.hidesBottomBarWhenPushed = YES;
    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    } else {
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}
#pragma mark - # SearchBar UI
- (WSSearchBar*)searchBar {
    if (!_searchBar) {
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        _searchBar = [[WSSearchBar alloc]  initWithFrame:rect isResetTextField:YES isResetBackgroundColor:NO isTop:YES];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        _searchBar.searchBar.delegate = self;
        NSString *placeholder = self.currentFuncs.opt.searchHint;
        if (placeholder.length == 0) {
            placeholder = NSLocalizedString(@"query_hint_label", nil);
        }
        [_searchBar setSearchBarPlaceholderWithText:placeholder color:[UIColor blackColor]];
    }
    return _searchBar;
}
- (void)setBarButtonTitle {
    NSString *currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];

    if (!currentCity) {
        currentCity = NSLocalizedString(@"beijing", nil);
    } else {
        currentCity = NSLocalizedString(currentCity, nil);
    }
    if (currentCity.length > 4) {
        NSString  *temString = [currentCity substringToIndex:3];
        currentCity = [NSString stringWithFormat:@"%@...",temString];
    }
    [_locationButton setTitle:currentCity];
    [UIView animateWithDuration:0.4 animations:^{
        _searchBar.alpha = 1;
    }];
    
}
- (void)addLocationBarButtonItem {
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    if (!_locationButton) {
        SEL selector = @selector(locationButtonClicked);
        UIBarButtonItem *locBBI = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:selector];
        if ([self.navigationController.navigationBar.backgroundColor isEqual:[UIColor whiteColor]] || [self.navigationController.navigationBar.backgroundColor isEqual:[UIColor clearColor]]) {
            [locBBI setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:UI_Font]} forState:UIControlStateNormal];
        }else
            [locBBI setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:UI_Font]} forState:UIControlStateNormal];
        
        _locationButton = locBBI;
        [barButtonItems addObject:_locationButton];
    }
    [self getNavigationItem].leftBarButtonItems = barButtonItems;
}
- (void)locationButtonClicked{
//    NSLog(@"重新定位并显示所在城市：%@", self.currentCity);

}
#pragma mark - # TableView
- (UITableView*)tableView {
    if(!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = kStoreRouteCellHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[WSNewRouteTableViewCell class] forCellReuseIdentifier:kStoreRouteCellId];
        [_tableView registerClass:[WSStoreRouteViewHeaderView class] forHeaderFooterViewReuseIdentifier:kStoreRouteHeaderId];
        [_tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.backgroundColor = HColorFromHex(0xEFF0F1);
    }
    return _tableView;
    
}
- (WSRouteStoreViewModel*)viewModel{
    if(!_viewModel){
        _viewModel = [[WSRouteStoreViewModel alloc]init];
    }
    return _viewModel;
}

@end
