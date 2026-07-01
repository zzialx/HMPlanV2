//
//  WSStoreRouteViewController.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/7.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreRouteViewController.h"
#import "WSRouteStoreListViewController.h"
#import "WinJSBridgeViewController.h"
#import "WSReportFormController.h"
#import "WSStoreRouteViewHeaderView.h"
#import "WSStoreRouteViewCell.h"
#import "MJRefresh.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSStoreRouteDataModel.h"
#import "WSEditableAcvtQstDBService.h"
#import "WSFuncsBeanArray.h"
#import "WSNewStoreListTool.h"

#define STORE_LIST_FV @"FV_NewStore_List" //门店列表FV标识
//==========================================================================================================================================

#pragma mark - 门店路线视图管理器 延展(内部)
@interface WSStoreRouteViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) WSSearchBar *searchBar;                   //搜索栏
@property (nonatomic, strong) UIBarButtonItem *locationButton;          //位置按键
@property (nonatomic, strong) WSStoreRouteViewHeaderView *headerView;   //头视图
@property (nonatomic, strong) UITableView *tableView;                   //表视图
@property (nonatomic, copy) NSString *keyWord;                          //搜索框内容
@property (nonatomic, strong) WSStoreRouteDataModel *routeModel;        //路线数据模型
@property (nonatomic, strong) NSIndexPath *selectIndexPah;              //当前选择单元格的索引路径
@property (nonatomic, copy) NSString *routeId;                          //路线ID

@end
//==========================================================================================================================================

#pragma mark - 门店路线视图管理器
@implementation WSStoreRouteViewController

#pragma mark - 获取searchBar方法
- (WSSearchBar *)searchBar {
    
    if (!_searchBar) {
        
        CGRect rect = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f);
        _searchBar = [[WSSearchBar alloc] initWithFrame:rect isResetTextField:YES isResetBackgroundColor:NO isTop:YES];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _searchBar.searchBar.delegate = self;
        
        NSString *placeholder = self.currentFuncs.opt.searchHint;
        if (placeholder.length == 0) {
            placeholder = NSLocalizedString(@"query_hint_label", nil);
        }
        [_searchBar setSearchBarPlaceholderWithText:placeholder color:[UIColor blackColor]];
    }
    
    return _searchBar;
}

#pragma mark - 获取headerView方法
- (WSStoreRouteViewHeaderView *)headerView {
    
    if (!_headerView) {
        
        _headerView = [[WSStoreRouteViewHeaderView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
    }
    return _headerView;
}

#pragma mark - 获取tableView方法
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    return _tableView;
}

#pragma mark - 获取locationButton方法
- (UIBarButtonItem *)locationButton {
    
    if (!_locationButton) {
        
        _locationButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonClicked)];
        
        if ([self.navigationController.navigationBar.backgroundColor isEqual:[UIColor whiteColor]] ||
            [self.navigationController.navigationBar.backgroundColor isEqual:[UIColor clearColor]]) {
            
            [_locationButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                                      NSFontAttributeName : [UIFont systemFontOfSize:UI_Font]} forState:UIControlStateNormal];
        }
        else {
            
            [_locationButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                      NSFontAttributeName : [UIFont systemFontOfSize:UI_Font]} forState:UIControlStateNormal];
        }
    }
    return _locationButton;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.tableView];
    
    [self setupHeaderView];
    [self setupTableView];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self getNavigationItem].titleView = self.searchBar;
    [self addLocationBarButtonItem];
    
    [self loadRoute];
}

#pragma mark - 设置头视图控件方法
- (void)setupHeaderView {
    
    __weak typeof(self) weakSelf = self;
    self.headerView.storeRouteHeaderClick = ^(WinStoreRouteHeaderClickType clickType) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (clickType == WinStoreRouteHeaderClickTypeSearch) {
            
            NSURL *url = [NSURL URLWithString:strongSelf.currentFuncs.opt.routeSearchurl];
            WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:url];
            rfvc.title = @"路线查询";
            [strongSelf gotToController:rfvc];
        }
        else if (clickType == WinStoreRouteHeaderClickTypeAdd) {
            
            WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
            vc.externalOpenUrl = strongSelf.currentFuncs.opt.addRouteUrl;
            [strongSelf gotToController:vc];
        }
        else if (clickType == WinStoreRouteHeaderClickTypeModify) {
            
            WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
            vc.externalOpenUrl = strongSelf.currentFuncs.opt.batchModifyUrl;
            [strongSelf gotToController:vc];
        }
    };
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
}

#pragma mark - 设置表视图控件方法
- (void)setupTableView {
    
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadRoute];
    }];
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - 添加位置导航项方法
- (void)addLocationBarButtonItem {
    
    [self getNavigationItem].leftBarButtonItems = nil;
    NSMutableArray *barButtonItems = [NSMutableArray array];
    [barButtonItems addObject:self.locationButton];
    [self getNavigationItem].leftBarButtonItems = barButtonItems;
    
    NSString *currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];
    currentCity = ((!currentCity) ? NSLocalizedString(@"beijing", nil) : NSLocalizedString(currentCity, nil));
    if (currentCity.length > 4) {
        NSString *temString = [currentCity substringToIndex:3];
        currentCity = [NSString stringWithFormat:@"%@...", temString];
    }
    [self.locationButton setTitle:currentCity];
}

#pragma mark - 实现numberOfSectionsInTableView:协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.routeModel.routs.count;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *storeRouteViewCellIdentifier = @"StoreRouteViewCellIdentifier";
    WSStoreRouteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:storeRouteViewCellIdentifier];
    if (!cell) {
        
        cell = [[WSStoreRouteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:storeRouteViewCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setupInfoWithModel:self.routeModel.routs[indexPath.row] routeId:self.routeModel.curRoute isLast:(indexPath.row == self.routeModel.routs.count - 1)];
    
    __weak typeof(self) weakSelf = self;
    
    cell.revokeActionBlock = ^(NSString *routeId) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.selectIndexPah = indexPath;
        [strongSelf p_revokeRouteAction];
    };
    
    cell.delegateActionBlock = ^(NSString *routeId) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.selectIndexPah = indexPath;
        [strongSelf p_delegateRouteAction];
    };
    
    cell.editActionBlock = ^(NSString *routeId) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
        vc.externalOpenUrl = strongSelf.currentFuncs.opt.jumpUrlLink;
        vc.externalInfoDic = @{Win_JSBridge_URL_Replacing_RouteId_Mark : routeId};
        [strongSelf gotToController:vc];
    };
    
    cell.executeActionBlock = ^(NSString *routeId) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.selectIndexPah = indexPath;
        [strongSelf p_executeRouteAction];
    };
    
    return cell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    WSStoreRouteDataInfoModel * routeModel = self.routeModel.routs[indexPath.row];
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *fb = [funcsArray getFuncsBeanWithFV:STORE_LIST_FV];
    if (!fb) {
        
        fb = [funcsArray getFuncsBeanWithFV:STORE_LIST_FV];
        if (!fb) {
            fb = [funcsArray getHideFuncsBeanWithFV:STORE_LIST_FV];
        }
    }
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    if ([vc isKindOfClass:[WSRouteStoreListViewController class]]) {
        
        WSRouteStoreListViewController *routeStoreListVC = (WSRouteStoreListViewController *)vc;
        routeStoreListVC.selectRouteId = routeModel.routeId;
        [self gotToController:routeStoreListVC];
    }
}

#pragma mark - 实现searchBarShouldEndEditing:协议
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
}

#pragma mark - 实现searchBarSearchButtonClicked:协议
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 实现searchBarTextDidEndEditing:协议
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    self.keyWord = searchBar.text;
    [self loadRoute];
}

#pragma mark - 查询当天是否第一次查询路线方法
- (BOOL)isFirstRoute {
    
    NSString *key = @"bizDateRoute";
    NSString *value = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *strDefault = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (strDefault && [strDefault isEqualToString:value]) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"routeId"];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

#pragma mark - 到达指定控制器方法
- (void)gotToController:(WCBaseViewController *)wfvc {
    
    LogInfo(@"WSStoreRouteViewController gotToController wfvc = %@", wfvc);
    
    wfvc.hidesBottomBarWhenPushed = YES;
    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    else {
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}

#pragma mark - 位置按键点击响应方法
- (void)locationButtonClicked {
    
}

#pragma mark - 加载路线方法(请求数据)
- (void)loadRoute {
    
    [SVProgressHUD showLoading];
    
    NSMutableDictionary*paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.ds] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:([self isFirstRoute] ? @"0" : @"1") forKey:@"reqFist"];
    [paramDic setObject:self.keyWord ? self.keyWord : @"" forKey:@"keyWord"];
    
    NSString *notifyID = @"Route";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 加载路线更新完成通知回调方法
- (void)uploadFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    [self.tableView.mj_header endRefreshing];
    [SVProgressHUD HideLoading];
    
    if ([notification.object isKindOfClass:[NSError class]]) {
        
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSDictionary *dic = [[notification object] objectFromJSONString];
    self.routeModel = [WSStoreRouteDataModel yy_modelWithDictionary:[dic objectForKey:[NSString stringNotNilWithValue:self.currentFuncs.ds]]];
    
    if (self.routeModel.curRoute && self.routeModel.curRoute.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.routeModel.curRoute forKey:@"routeId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (self.routeModel.planRoute && self.routeModel.planRoute.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.routeModel.planRoute forKey:@"routeId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    WSEditableAcvtQstDBService *service = [[WSEditableAcvtQstDBService alloc] init];
    NSMutableArray *storeArr = [NSMutableArray arrayWithCapacity:0];
    for (WSStoreRouteDataInfoModel *routeDataInfoModel in self.routeModel.routs) {
        
        NSString *routeApproveState = (routeDataInfoModel.approveState.length == 0) ? @"" : routeDataInfoModel.approveState;
        
        for (WSStoreDataInfoModel *dataInfoModel in routeDataInfoModel.stores) {
            
            NSDictionary *dic = @{@"store_id" : dataInfoModel.storeId, @"value" : dataInfoModel.state, @"id" : routeDataInfoModel.routeId,
                                  @"type" : VISIT_PLAN_ROUTE, @"empId" : @(dataInfoModel.sort), @"acvtId" : routeApproveState};
            [storeArr addObject:dic];
        }
    }
    [service replaceToTableWithDicts:storeArr FromNode:VISIT_PLAN_ROUTE hasNewData:YES];
    
    [self.headerView setInfoWithData:self.routeModel];
    [self.tableView reloadData];
}

#pragma mark - 路线撤销方法(单元格内点击撤销路线按键响应方法)
- (void)p_revokeRouteAction {
    
    __weak typeof(self) weakSelf = self;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                                             message:@"确认是否需要进行撤销操作？"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil)
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf requestRevokeRoute];
    }];
    [okAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 请求撤销路线方法
- (void)requestRevokeRoute {
    
    [SVProgressHUD showLoading];
    
    WSStoreRouteDataInfoModel *model = self.routeModel.routs[self.selectIndexPah.row];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"bizDate"];
    [parameters setObject:@"cancelRoute" forKey:@"objId"];
    [parameters setObject:ISNULL(model.routeId) forKey:@"routeId"];
    [parameters setObject:ISNULL(model.approveId) forKey:@"approveId"];
    
    __weak typeof(self) weakSelf = self;
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD HideLoading];
        
        NSDictionary *responseDic = [response jsonResponse];
        if ([responseDic.allKeys containsObject:@"cancelRoute"]) {
            
            NSString *revokeRoute = [NSString stringWithFormat:@"%@", [responseDic objectForKey:@"cancelRoute"]];
            if ([revokeRoute isEqualToString:@"1"]) {
                [SVProgressHUD showHudMsg:@"路线撤销成功"];
            }
            else {
                [SVProgressHUD showHudMsg:@"路线撤销失败"];
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [strongSelf loadRoute];
        });
    }
                                                      failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        [SVProgressHUD HideLoading];
        [SVProgressHUD showHudMsg:response.error.titleForError];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadRoute];
    }];
}

#pragma mark - 路线删除方法(单元格内点击删除路线按键响应方法)
- (void)p_delegateRouteAction {
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                                             message:@"确认是否需要进行删除操作？"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil)
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf requestDelegateRoute];
    }];
    [okAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 请求删除路线方法
- (void)requestDelegateRoute {
    
    [SVProgressHUD showLoading];
    
    WSStoreRouteDataInfoModel *model = self.routeModel.routs[self.selectIndexPah.row];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"bizDate"];
    [parameters setObject:@"deleteRoute" forKey:@"objId"];
    [parameters setObject:ISNULL(model.routeId) forKey:@"routeId"];
    
    __weak typeof(self) weakSelf = self;
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD HideLoading];
        
        NSDictionary *responseDic = [response jsonResponse];
        if ([responseDic.allKeys containsObject:@"deleteRoute"]) {
            
            NSString *deleteRoute = [NSString stringWithFormat:@"%@", [responseDic objectForKey:@"deleteRoute"]];
            if ([deleteRoute isEqualToString:@"1"]) {
                [SVProgressHUD showHudMsg:@"路线删除成功"];
            }
            else {
                [SVProgressHUD showHudMsg:@"路线删除失败"];
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [strongSelf loadRoute];
        });
    }
                                                      failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        [SVProgressHUD HideLoading];
        [SVProgressHUD showHudMsg:response.error.titleForError];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadRoute];
    }];
}

#pragma mark - 路线切换方法(单元格内点击执行路线按键响应方法)
- (void)p_executeRouteAction {
        
    WSStoreRouteDataInfoModel *model = self.routeModel.routs[self.selectIndexPah.row];
    LogInfo(@"p_RouteLineSwitch 切换路线id =%@= =%@=", model.routeId, model.routeName);
    
    //切换相同路线
    if ([self.routeModel.curRoute isEqualToString:model.routeId]) {
        
        LogInfo(@"p_RouteLineSwitch 相同路线id =%@= =%@= =%@=", model.routeId, model.routeName, self.routeModel.curRoute);
        [self.routeModel setCurRoute:model.routeId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"routeSelect" object:self];
        
        return;
    }
    
    //查询执行中的路线
    WSStoreRouteDataInfoModel *lastRoutModel;
    for (WSStoreRouteDataInfoModel *routeModel in self.routeModel.routs) {
        
        LogInfo(@"p_RouteLineSwitch 查询所有的执行路线 id =%@= =%@=", routeModel.routeId, self.routeModel.curRoute);
        if ([routeModel.routeId isEqualToString:self.routeModel.curRoute]) {
            lastRoutModel = routeModel;
            break;
        }
    }
    
    //查询当前线路的执行进度
    NSString *curRouteprogress = @"";
    if (lastRoutModel) {
         
        curRouteprogress = [NSString stringWithFormat:@"%ld%@", lastRoutModel.rexecNum * 100 / (lastRoutModel.rtotal > 0  ? lastRoutModel.rtotal : 1), @"%"];
        LogInfo(@"p_RouteLineSwitch 上一次选择路线id =%@= =%@= 上一次选择路线执行进度 =%@= ", lastRoutModel.routeId, lastRoutModel.routeName, curRouteprogress);

        //服务器数据 tipFlag 这条路线有没有门店拜访 1代表路线上的门店有访问 0代表没有访问可以直接切换
        if ([self.routeModel.tipFlag isEqualToString:@"1"]) {
            if (![curRouteprogress isEqualToString:@"100%"]) {
                
                LogInfo(@"p_RouteLineSwitch 上一次选择路线执行进度 =%@= 当前执行的路线id =%@=", curRouteprogress, self.routeModel.curRoute);
                [self addAlertVCWithMsg:@"线路执行期间，请勿切换路线"];
                return;
            }
        }
    }
    else {
        LogInfo(@"p_RouteLineSwitch 没有查询到上一次执行路线");
    }
    
    //其它门店正在拜访
    if (![WSNewStoreListTool anyStoreHasNotLeave:nil andModuleFC:nil withCurrentFuncs:nil]) {
        return;
    }
    
    //弹框提示
    NSString *alertMsg = [NSString stringWithFormat:@"%@%@%@%@",
                          NSLocalizedString(@"route_setup", nil), model.routeName, NSLocalizedString(@"route_do", nil), NSLocalizedString(@"route_todayRoute", nil)];
    [self p_addRouteLineSwitchAlertWithMsg:alertMsg routeModel:model];
}

#pragma mark - 添加警示框方法
- (void)addAlertVCWithMsg:(NSString *)msg {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                                             message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:nil];
    [okAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 添加切换线路警告方法
- (void)p_addRouteLineSwitchAlertWithMsg:(NSString *)msg routeModel:(WSStoreRouteDataInfoModel *)routeModel {
    
    __weak typeof(self) weakSelf = self;
    __block NSString *blockRouteId = routeModel.routeId;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.routeModel setCurRoute:blockRouteId];
        [strongSelf loadRouteLastTimeWithRouteId:blockRouteId];
    }];
    [okAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:kAlertViewButtonTextColor forKey:@"titleTextColor"];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 切换路线请求方法
- (void)loadRouteLastTimeWithRouteId:(NSString *)routeId {
    
    self.routeId = routeId;
    
    [self querying_messageTips];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:routeId forKey:@"routeId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"bizDate"];
    
    NSString *notifyID = @"RouteId";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadRouteLastTimeFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 切换路线请求通知回调方法
- (void)uploadRouteLastTimeFinish:(NSNotification *)notification {
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if ([notification.object isKindOfClass:[NSError class]]) {
        
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSDictionary *dic = [[notification object] objectFromJSONString];
    if ([dic objectForKey:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag]] &&
        [[dic objectForKey:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag]] isEqualToString:@"1"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:self.routeId forKey:@"routeId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"routeSelect" object:self];
    }
}

@end
//==========================================================================================================================================
