//
//  WSStoreManageSearchViewController.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/13.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreManageSearchViewController.h"
#import "WSBaseAcvtDBService.h"
#import "WSAddNewStoreViewController.h"
#import "WSRequestHelper.h"
#import "WSStoreManageViewCell.h"
#import "WSStoreManageDataModel.h"
#import "YYModel.h"
#import "WSStoresSearchDataModel.h"
#import "WSStoresSearchTableViewCell.h"
#import "MJRefresh.h"
#import "WSStoreDataProcessService.h"
#import "Md5Manager.h"

static CGFloat const kStoreManageSearchCellHeight = 110;
static NSString * const kStoreManageSearchCellId = @"StoreManageSearchCellId";
static NSString * const kStoresSearchCellId = @"StoresSearchCellId";
//====================================================================================================================================================================================

@interface WSStoreManageSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WSStoreManageDataModel *manageModel;
@property (nonatomic, strong) WSStoresSearchDataModel *storesSearchModel;
@property (nonatomic, strong) WSStoresSearchDataInfoModel *storesSearchDataInfoModel;
@property (nonatomic, strong) WSSearchBar *searchBar;
@property (nonatomic, strong) NSString *searchKey;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSString *genId;
@property (nonatomic, strong) NSMutableArray *manageDataArray;

@end
//====================================================================================================================================================================================

@implementation WSStoreManageSearchViewController

#pragma mark - 获取manageDataArray方法
- (NSMutableArray *)manageDataArray {
    
    if (!_manageDataArray) {
        _manageDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _manageDataArray;
}

#pragma mark - 重写
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self addControls];
    [self addEmptyView];
    
    self.pageIndex = 1;
    if (self.currentAcvt) {
        
        __weak typeof(self) wself = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.pageIndex = 1;
            [wself loadStoreManage];
        }];
        header.automaticallyChangeAlpha = YES;
        self.tableView.mj_header = header;
        
        self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            self.pageIndex++;
            [wself loadStoreManage];
        }];
    }
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    [self layoutControls];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.currentAcvt) {
        self.pageIndex = 1;
        [self loadStoreManage];
    }
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

#pragma mark - 添加控件方法
- (void)addControls {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    tableView.rowHeight = kStoreManageSearchCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    if (self.currentAcvt) {
        [tableView registerClass:[WSStoresSearchTableViewCell class] forCellReuseIdentifier:kStoresSearchCellId];
    }
    else {
        [tableView registerClass:[WSStoreManageViewCell class] forCellReuseIdentifier:kStoreManageSearchCellId];
    }
    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    _searchBar = [[WSSearchBar alloc]  initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44) isResetTextField:YES isResetBackgroundColor:NO isTop:YES];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _searchBar.searchBar.delegate = self;
    NSString * placeholder = @"";
    if (placeholder.length == 0) {
        placeholder = NSLocalizedString(@"query_hint_label", nil);
    }
    _searchBar.searchBar.placeholder = placeholder;
    UITextField *searchField = [_searchBar.searchBar valueForKey:@"searchField"];
    if (searchField) {
        if (@available(iOS 13.0, *)) {
            searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        }
        else {
            [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
    self.navigationItem.titleView =_searchBar;
}

#pragma mark - 布局子视图方法
- (void)layoutControls {
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    self.tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
}

#pragma mark - 加载门店信息方法
- (void)loadStoreManage {
    
    [self querying_messageTips];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.searchKey] forKey:@"searchKey"];

    if (!self.currentAcvt) {
        
        [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag] forKey:@"objId"];
        NSString *notifyID = @"StoreManagesSearchKey";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
        [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
    }
    else {
        
        [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchQuestion] forKey:@"objId"];
        [paramDic setObject:@(self.pageIndex) forKey:@"pageIndex"];
        [paramDic setObject:[NSString stringNotNilWithValue:self.currentAcvt.acvtCode] forKey:@"acvtCode"];
        NSString *notifyID = @"StoresSearchKey";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStoresFinish:) name:notifyID object:nil];
        [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
    }
}

#pragma mark - 更新完成通知回调方法(!self.currentAcvt时 请求的接口)
- (void)uploadFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if ([notification.object isKindOfClass:[NSError class]]) {
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSDictionary *dic = [[notification object] objectFromJSONString];
    self.manageModel = [WSStoreManageDataModel yy_modelWithDictionary:dic];
    if (self.manageModel  && self.manageModel.spestorelist.count > 0) {
        
        [self.empty removeFromSuperview];
        self.empty = nil;
    }
    else {
        
        if (!self.empty) {
            [self addEmptyView];
        }
    }
        
    [self.tableView reloadData];
}

#pragma mark - 更新门店完成回调方法(self.currentAcvt时 请求的接口)
- (void)uploadStoresFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
    
    if ([notification.object isKindOfClass:[NSError class]]) {
        
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        if (self.pageIndex > 1) {
            self.pageIndex--;
        }
        return;
    }
    
    NSDictionary *dic = [[notification object] objectFromJSONString];
    self.storesSearchModel = [WSStoresSearchDataModel yy_modelWithDictionary:dic];
    if (self.storesSearchModel && self.storesSearchModel.spestoreSearchList.count > 0) {
        
        if (self.pageIndex == 1 ) {
            [self.manageDataArray removeAllObjects];
        }
        [self.manageDataArray addObjectsFromArray:self.storesSearchModel.spestoreSearchList];
            
        if (self.storesSearchModel.spestoreSearchList.count < 20) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
    else if (self.pageIndex > 1) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
   
    if (self.manageDataArray.count > 0) {
        [self.empty removeFromSuperview];
        self.empty = nil;
    }
    else {
        if (!self.empty) {
            [self addEmptyView];
        }
    }
       
    [self.tableView reloadData];
}

#pragma mark - 加载问卷信息方法
- (void)loadAcvtDis {
    
    self.genId = [Md5Manager getMd5ByEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                   sotreId:[NSString stringNotNilWithValue:@(self.storesSearchDataInfoModel.storeId)]
                                   bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]
                                  funcCode:self.currentFuncs.fc
                                    acvtId:self.currentAcvt.acvtId
                                      memo:@""
                                  dateType:self.currentAcvt.dateTyp];
    
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:@"" forKey:@"changeFlage"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.refreshNodeName] forKey:@"objId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentAcvt.acvtId] forKey:@"extra_acvtId"];
    [paramDic setObject:[NSString stringNotNilWithValue:@(self.storesSearchDataInfoModel.storeId)] forKey:@"storeId"];
    [paramDic setObject:self.genId  forKey:@"genId"];
    NSString *notifyID = @"loadAcvtDis";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAcvtDisUploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 加载问卷信息通知回调方法
- (void)loadAcvtDisUploadFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if ([notification.object isKindOfClass:[NSError class]]) {
        
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSDictionary *dic = [[notification object] objectFromJSONString];
    if (dic && [dic objectForKey:self.currentFuncs.opt.refreshNodeName]) {
        
        WSStoreBean *storeBean = [[WSStoreBean alloc] init];
        storeBean.Id = [NSString stringWithFormat:@"%ld",self.storesSearchDataInfoModel.storeId];
        storeBean.name = self.storesSearchDataInfoModel.name;
        storeBean.addr = self.storesSearchDataInfoModel.addr;
        storeBean.code = self.storesSearchDataInfoModel.code;
        storeBean.level_code =  self.storesSearchDataInfoModel.lvlcode;
        [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:dic genId:nil isRemoteSearch:NO];
            
        WSAcvtViewController *acvtController = [[WSAcvtViewController alloc] initWithAcvt:self.currentAcvt Funcs:self.currentFuncs Store:storeBean md5:self.genId
                                                                       isFromRealTimeData:YES
                                                                                 SubEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        acvtController.title = ((self.currentAcvt.acvtName.length > 0) ? self.currentAcvt.acvtName : acvtController.title);

        if (self.ownParentViewController) {
            [self.ownParentViewController.navigationController pushViewController:acvtController animated:YES];
        }
        else {
            [self.navigationController pushViewController:acvtController animated:YES];
        }
    }
}

#pragma mark - 实现searchBarTextDidBeginEditing:协议
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - 实现searchBarCancelButtonClicked:协议
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - 实现searchBar:textDidChange:协议
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

#pragma mark - 实现searchBarTextDidEndEditing:协议
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}

#pragma mark - 实现searchBarSearchButtonClicked:协议
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar resignFirstResponder];
    
    self.searchKey = searchBar.text;
    self.pageIndex = 1;
    self.tableView.mj_footer.hidden = NO;
    [self loadStoreManage];
}

#pragma mark - 实现numberOfSectionsInTableView:协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.currentAcvt) {
        return self.manageDataArray.count;
    }
    return self.manageModel.spestorelist.count;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.currentAcvt) {
        
        WSStoresSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoresSearchCellId forIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.model = self.manageDataArray[indexPath.row];
        return cell;
    }
    
    WSStoreManageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoreManageSearchCellId forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.model = self.manageModel.spestorelist[indexPath.row];
    return cell;
}

#pragma mark - 实现tableView:heightForHeaderInSection:协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (!self.currentAcvt) {
        return;
    }
        
    WSStoresSearchDataInfoModel *model = self.manageDataArray[indexPath.row];
    self.storesSearchDataInfoModel = model;
    NSString *strMessage = @"";
    if ([model.cpyCode isEqualToString:@"0"]) {
        strMessage = @"其他业代的客户不能进行更新操作";
    }
    else {
        if ([model.ts isEqualToString:@"0"]) {
            strMessage = @"该门店本月已提交过申请或存在待审批申请，不能在提交申请";
        }
        else {
            if (self.storeManageDelegate) {
                [self.storeManageDelegate sotreDataInfoModel:model];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self loadAcvtDis];
            }
            return;
        }
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellH = kStoreManageSearchCellHeight;
    if (!self.currentAcvt) {
       
        WSStoreManageDataInfoModel *infoModel = self.manageModel.spestorelist[indexPath.row];
        if (infoModel.refuseReason && infoModel.refuseReason.length > 0) {
            cellH += 25;
        }
        if ([infoModel.changeFlage isEqualToString:@"1"] || [infoModel.changeFlage isEqualToString:@"2"]) {
            cellH += 45;
        }
    }
    else {
        cellH += 25;
    }
    
    return cellH;
}

@end
