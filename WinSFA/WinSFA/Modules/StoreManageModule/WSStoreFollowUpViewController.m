//
//  WSStoreFollowUpViewController.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/21.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSStoreFollowUpViewController.h"
#import "WSStoreFollowUpHeaderFooterView.h"
#import "WSStoreFollowUpTableViewCell.h"
#import "WSStoreFollowUpDataModel.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSAddFollowUpStoreListViewController.h"
#import "NSDate+Formatter.h"
#import "WSStoreDataProcessService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSWorkFlowViewController.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "MJRefresh.h"

static CGFloat const kStoreFollowUpCellHeight = 125;
static CGFloat const kStoreFollowUpHeaderHeight = 50;
static NSString * const kStoreFollowUpCellId = @"StoreFollowUpCellId";
static NSString * const kStoreFollowUpHeaderId = @"StoreFollowUpHeaderId";
static NSString * titleName = @"下拉刷新";

@interface WSStoreFollowUpViewController () <UITableViewDataSource, UITableViewDelegate, WSStoreFollowUpTableViewCellDelegate>

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *followUpDataArray;
@property (nonatomic, strong) WSStoreFollowUpDataModel *followUpDataModel;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation WSStoreFollowUpViewController

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSMutableArray *barButtonItems = [[NSMutableArray alloc]init];
    UIBarButtonItem *buttonItem = nil;
    buttonItem = [self barButtonItemTitle:@"添加" target:self action:@selector(addBtnDown)];
    [barButtonItems addObject:buttonItem];
    if (self.ownParentViewController){
        self.ownParentViewController.navigationItem.rightBarButtonItems = barButtonItems;
    }
    else {
        self.navigationItem.rightBarButtonItems = barButtonItems;
    }
    [self addControls];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self loadStoreFollowUp];
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    self.headView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 30.0f);
    self.tableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headView.frame)));
    self.empty.frame = CGRectMake(0.0f, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headView.frame)));
}

#pragma mark - 添加控制视图方法
- (void)addControls {
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    headView.backgroundColor = HColorFromHex(0xE6F8E1);
    [self.view addSubview:headView];
    headView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
    headView.layer.shadowOffset = CGSizeMake(0,0);
    headView.layer.shadowRadius = 8;
    headView.layer.shadowOpacity = 1;
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(0, 0, self.view.width, 30);
    [refreshBtn setTitle:titleName forState:UIControlStateNormal];
    [refreshBtn setTitleColor:HColorFromHex(0x28A707) forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = FONT(14.0);
    [refreshBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [refreshBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -refreshBtn.imageView.image.size.width-5, 0, refreshBtn.imageView.image.size.width)];
    [refreshBtn setImageEdgeInsets:UIEdgeInsetsMake(0, refreshBtn.titleLabel.bounds.size.width, 0, -refreshBtn.titleLabel.bounds.size.width-5)];
    [refreshBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:refreshBtn];
    _headView = headView;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 50 - NavigationBarHeight)];
    tableView.rowHeight = kStoreFollowUpCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSStoreFollowUpTableViewCell class] forCellReuseIdentifier:kStoreFollowUpCellId];
    [tableView registerClass:[WSStoreFollowUpHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kStoreFollowUpHeaderId];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    @weakify_self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadStoreFollowUp];
    }];
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
}

#pragma mark - 刷新按键响应方法
- (void)refreshAction {
    
    [self loadStoreFollowUp];
}

#pragma mark - 加载数据方法
- (void)loadStoreFollowUp {
    
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.ds] forKey:@"objId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.filter] forKey:@"filter"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"StoreFollowUp";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 加载数据回调方法
- (void)uploadFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    [self.tableView.mj_header endRefreshing];
    
    if (![notification.object isKindOfClass:[NSError class]]) {
        
        NSDictionary *dic = [[notification object] objectFromJSONString];
        dic = [dic objectForKey:self.currentFuncs.ds];
        self.followUpDataModel = [WSStoreFollowUpDataModel yy_modelWithDictionary:dic];
        self.followUpDataArray = [NSMutableArray arrayWithArray:self.followUpDataModel.followUpList];
        if (self.followUpDataArray && self.followUpDataArray.count > 0) {
            
            [self.empty removeFromSuperview];
            self.empty = nil;
        }
        else {
            
            if (!self.empty) {
                
                [self addEmptyView];
                self.empty.frame = CGRectMake(0.0f, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headView.frame)));
            }
        }
        [self.tableView reloadData];
    }
    else {
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

#pragma mark - 布局控制视图方法
- (void)layoutControls {
    
//    CGFloat viewWidth = self.view.frame.size.width;
//    CGFloat viewHeight = self.view.frame.size.height;
//    self.tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    
    self.headView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 30.0f);
    self.tableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headView.frame)));
    self.empty.frame = CGRectMake(0.0f, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headView.frame)));
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.followUpDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSStoreFollowUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoreFollowUpCellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.followUpDataArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.followUpTableViewCellDelegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    WSStoreFollowUpHeaderFooterView *headerView = (WSStoreFollowUpHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kStoreFollowUpHeaderId];
    [headerView setWithPlanNum:self.followUpDataModel.planNum endNum:self.followUpDataModel.endNum noFollowUpNum:self.followUpDataModel.noFollowUpNum];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return kStoreFollowUpHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellH = kStoreFollowUpCellHeight;
    WSStoreFollowUpInfoDataModel *infoModel = self.followUpDataArray[indexPath.row];
    if (infoModel.superiorEmpName && infoModel.superiorEmpName.length > 0) {
        
        cellH += 25;
    }
    return cellH;
}

- (void)btnDownFollowUpDelegate:(NSIndexPath *)IndexPath {
    
    self.selectIndexPath = IndexPath;
    WSStoreFollowUpInfoDataModel *model =  self.followUpDataArray[IndexPath.row];
    if([model.state isEqualToString:@"1"]){
        [self startUpdata];
        return;
    }
    
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:@"getStoreVisitState"] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:[NSString stringNotNilWithValue:model.storeId] forKey:@"storeId"];
    if (model.leaderId) {
        [paramDic setObject:[NSString stringNotNilWithValue:model.leaderId] forKey:@"leaderId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:model.empId] forKey:@"salesId"];
    
    NSString *notifyID = @"getStoreVisitState";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStoreVisitStateFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

- (void)btnDownCancelFollowUpDelegate:(NSIndexPath *)IndexPath {
    
    self.selectIndexPath = IndexPath;
    
    __weak typeof(self)weakSelf = self;
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"确定取消该随访？", nil) message:nil];
    [alert addButtonWithTitle:@"确定" block:^{
        [weakSelf uploadCancelFollowUp];
    }];
    [alert setCancelButtonWithTitle:@"取消" block:^{
    }];
    [alert show];
}

- (void)uploadCancelFollowUp {
    
    WSStoreFollowUpInfoDataModel *model = self.followUpDataArray[self.selectIndexPath.row];
    [self querying_messageTips];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    NSDate *date = [NSDate date];
    if (self.currentFuncs.opt.saveNode.length > 0) {
        [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.saveNode] forKey:@"objId"];
    }
    else {
        [paramDic setObject:[NSString stringNotNilWithValue:@"saveFollowUpStore"] forKey:@"objId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:model.storeId] forKey:@"storeId"];
    if (model.leaderId) {
        [paramDic setObject:[NSString stringNotNilWithValue:model.leaderId] forKey:@"leaderId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:model.empId] forKey:@"salesId"];
    [paramDic setObject:[NSString stringNotNilWithValue:date.yyyyMMddByLineWithDate] forKey:@"bizDate"];
    [paramDic setObject:[NSString stringNotNilWithValue:@"0"] forKey:@"type"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    
    NSString *notifyID = @"saveCancelFollowUpStore";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSaveCancelFollowUpStoreFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

- (void)uploadStoreVisitStateFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if (![notification.object isKindOfClass:[NSError class]]) {
        
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if (dic && [dic objectForKey:@"getStoreVisitState"] && [[dic objectForKey:@"getStoreVisitState"] integerValue] == 1) {
            
            [self startUpdata];
        }
        else {
            
            if (self.currentFuncs.filter && [self.currentFuncs.filter isEqualToString:@"zg"]) {
                [MBProgressHUD showHUDAddedTo:self.view withText:@"该主管未随访进入该门店" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            else {
                [MBProgressHUD showHUDAddedTo:self.view withText:@"该业代未进入该门店" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
        }
    }
    else {
        
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (void)uploadSaveCancelFollowUpStoreFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if (![notification.object isKindOfClass:[NSError class]]) {
        
        NSDictionary *dic = [[notification object] objectFromJSONString];
        NSString * objId = @"saveFollowUpStore";
        if (self.currentFuncs.opt.saveNode.length >  0) {
            objId = self.currentFuncs.opt.saveNode;
        }
        if (dic && [dic objectForKey:objId]&& [[dic objectForKey:objId] integerValue] == 1) {
            [self loadStoreFollowUp];
        }
        else {
            [MBProgressHUD showHUDAddedTo:self.view withText:@"取消随访失败！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }
    else {
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (void)addBtnDown {
    
    WSAddFollowUpStoreListViewController* storeList;
    WSFuncsBean *fc = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByFuncsCode:@"TAB_F5001_AT03"];
    if(fc) {
        storeList = [[NSClassFromString(@"WSAddFollowUpStoreListViewController") alloc] initWithFuncs:fc];
    }
    else {
        storeList = [[WSAddFollowUpStoreListViewController alloc] init];
    }
    storeList.filter = self.currentFuncs.filter;
    [self.navigationController pushViewController:storeList animated:YES];
}

- (void)startUpdata {
    
    WSStoreFollowUpInfoDataModel *model = self.followUpDataArray[self.selectIndexPath.row];
    self.currentStore = [[WSStoreBean alloc] init];
    self.currentStore.Id = model.storeId;
    self.currentStore.name = model.storeName;
    self.currentStore.addr = model.storeAddr;
    self.currentStore.srid = model.empId;
    self.subempStore = [[WSSubempstoreBean alloc] init];
    self.subempStore.Id = model.empId;
    self.subempStore.name = model.empName;
    self.subempStore.empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    self.currentStore.isRestSrid = YES;
    if (model.leaderId) {
        self.subempStore.Id = model.leaderId;
        self.currentStore.srid = model.leaderId;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishUploadFollowUpStoreRequest:) name:@"uploadFollowUpStore" object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataManagerInfo:self.currentStore subempId:model.empId withObjId:ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME notifyName:@"uploadFollowUpStore" styp:nil];
    
    [self querying_messageTips];
}

- (void)finishUploadFollowUpStoreRequest:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"uploadFollowUpStore" object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        
        NSString *tmpString = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSDictionary *uploadState = [info objectFromJSONString];
    NSString *objId = ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    NSObject *tmpObject = uploadState[objId];
    NSDictionary *storeDicInfo = nil;
    
    if ([tmpObject isKindOfClass:[NSDictionary class]]) {
        storeDicInfo = (NSDictionary *)tmpObject;
    }
    else if ([tmpObject isKindOfClass:[NSArray class]]) {
        storeDicInfo = [(NSArray *)tmpObject firstObject];
    }
    
    if (self.currentStore != nil) {
            
        [self.currentStore reSetStore:uploadState Key:objId];
    
        [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
        NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
        [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id ];
        WSWorkFlowViewController* wfvc = nil;
        WSFuncsBean *funcBean = self.currentFuncs;
        if (self.currentFuncs.submenu && self.currentFuncs.submenu.length > 0) {
            funcBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByFuncsCode:@"TAB_F5001_AT01"];
        }
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:funcBean Store:self.currentStore subEmpStore:self.subempStore];
        wfvc.title = self.currentStore.name;
        wfvc.moduleFC = funcBean.fc;
        wfvc.input_reflect_code =funcBean.fc;
        
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}

@end
