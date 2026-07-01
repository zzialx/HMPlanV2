//
//  WSStoreManagementViewController.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/6.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreManagementViewController.h"
#import "WSBaseAcvtDBService.h"
#import "WCPopListView.h"
#import "WSAddNewStoreViewController.h"
#import "WSRequestHelper.h"
#import "WSStoreManageViewHeaderView.h"
#import "WSStoreManageViewCell.h"
#import "WSStoreManageDataModel.h"
#import "YYModel.h"
#import "WSStoreManageSearchViewController.h"
#import "WSStoreDataProcessService.h"
#import "WSBaseStoreOtherDataTable.h"

static CGFloat const kStoreManageCellHeight = 110;                      //单元格高度
static CGFloat const kStoreManageHeaderHeight = 30;                     //表视图头部视图高度
static NSString * const kStoreManageCellId = @"StoreManageCellId";      //表视图单元格标识
static NSString * const kStoreManageHeaderId = @"StoreManageHeaderId";  //表视图头部视图标识
//========================================================================================================================================================================

#pragma mark - 门店管理视图管理器 延展(内部)
@interface WSStoreManagementViewController () <UITableViewDelegate, UITableViewDataSource, WCPopListViewDelegate, WSStoreManageViewHeaderViewDelegate, WSStoreManageViewCellDelegate>

@property (nonatomic, copy) NSString *timesStr;                                 //时间标识
@property (nonatomic, strong) NSArray *addAcvtArray;                            //问卷数组
@property (nonatomic, strong) UITableView *tableView;                           //表视图
@property (nonatomic, strong) WSStoreManageDataModel *manageModel;              //门店管理模型
@property (nonatomic, strong) NSMutableArray *manageDataArray;                  //门店管理数据
@property (nonatomic, strong) WSStoreManageDataInfoModel *storeManageDataInfo;  //当前管理信息模型
@property (nonatomic, strong) WSStoreManageViewHeaderView *headerView;          //表视图头部展示视图

@end
//========================================================================================================================================================================

#pragma mark - 门店管理视图管理器
@implementation WSStoreManagementViewController

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self addControls];
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    [self layoutControls];
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self loadStoreManage];
    
    NSMutableArray *barButtonItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *buttonItem = nil;
    if (self.currentFuncs.buttonName) {
        buttonItem = [self barButtonItemImage:@"title-bar_create_icon" target:self action:@selector(addNewAcvt:)];
        [barButtonItems addObject:buttonItem];
    }
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItems = barButtonItems;
    } else {
        self.navigationItem.rightBarButtonItems = barButtonItems;
    }
}

#pragma mark - 获取timesStr方法
- (NSString *)timesStr {
    
    if (!_timesStr) {
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
        [formatter setDateFormat:@"yyyy-MM"];
        _timesStr = [formatter stringFromDate:date];
    }
    return _timesStr;
}

#pragma mark - 获取addAcvtArray方法
- (NSArray *)addAcvtArray {
    
    if (!_addAcvtArray || [_addAcvtArray count] == 0) {
        
        NSString *isAdd = self.currentFuncs.opt.isAdd;
        if (!(isAdd && [isAdd isEqualToString:@"N"])) {
            
            WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
            _addAcvtArray = [service queryAcvtsByFilter:self.currentFuncs.filter acvtCode:self.currentFuncs.opt.isAdd];
        }
    }
    return _addAcvtArray;
}

#pragma mark - 添加控件方法
- (void)addControls {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = kStoreManageCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSStoreManageViewCell class] forCellReuseIdentifier:kStoreManageCellId];
    [tableView registerClass:[WSStoreManageViewHeaderView class] forHeaderFooterViewReuseIdentifier:kStoreManageHeaderId];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    WSStoreManageViewHeaderView *tableHeaderView = [[WSStoreManageViewHeaderView alloc] initWithFrame:CGRectZero];
    tableHeaderView.iDelegate = self;
    tableView.tableHeaderView = tableHeaderView;
    self.headerView = tableHeaderView;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
}

#pragma mark - 布局控件方法
- (void)layoutControls {
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    self.tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    self.headerView.frame = CGRectMake(0, 0, viewWidth, 30.0f);
}

#pragma mark - 加载门店管理信息方法(实时请求接口)
- (void)loadStoreManage {
    
    [self querying_messageTips];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:self.timesStr forKey:@"searchMonth"];
    NSString *notifyID = @"StoreManage";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 加载门店管理信息请求通知回调方法
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
    self.manageDataArray = [NSMutableArray arrayWithArray:self.manageModel.spestorelist];
    
    if(self.manageDataArray && self.manageDataArray.count > 0) {
        
        [self.empty removeFromSuperview];
        self.empty = nil;
    }
    else {
        
        if (!self.empty) {
            [self addEmptyView];
            self.empty.frame = CGRectMake(self.empty.frame.origin.x, self.empty.frame.origin.y + kStoreManageHeaderHeight, self.empty.frame.size.width, self.empty.frame.size.height - kStoreManageHeaderHeight);
        }
    }
    
    [self.headerView setupStatetWithTitle:@"全 部"];
    [self.tableView reloadData];
}

#pragma mark - 添加新调查问卷方法(导航栏右按键响应方法)
- (void)addNewAcvt:(id)sender {
    
    LogTrace();
    
    NSString *isAdd = self.currentFuncs.opt.isAdd;
    if ([isAdd isEqualToString:@"N"]) {
        return;
    }
    
    if ([self.addAcvtArray count] == 0) {
        return;
    }
    
    if ([self.addAcvtArray count] == 1) {
        [self showAcvtViewController:[self.addAcvtArray firstObject]];
        return;
    }
        
    [self addPopView];
}
- (void)addPopView{
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *rootView = delegate.window.rootViewController.view;
    NSArray *acvtNameArray = [self.addAcvtArray valueForKeyPath:@"@unionOfObjects.acvtName"];
            
    WCPopListView *view = [[WCPopListView alloc] initWithTotalArry:acvtNameArray selectedArray:nil withSelectedMode:WCPopListSigleSelected
                                                     animationType:WCPopListAnimationTypeFromPoint maxHeight:(rootView.height - 64)];
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    view.animationPoint = CGPointMake(rootView.width - 20, 40);
    view.autoHideWhenSelect = YES;
    [view setPopListViewColor:[UIColor clearColor]];
    view.iDelegate = self;
    CGFloat popListHeight = self.view.height;
    if ([acvtNameArray count] * WCROWHEIGHT <  popListHeight) {
        popListHeight = [acvtNameArray count] * WCROWHEIGHT;
    }
    if (!IOS8_OR_LATER && INTERFACE_IS_PAD) {
        [view showViewFromRect:CGRectMake(rootView.height - WCPOPLISTWIDTH, 64, WCPOPLISTWIDTH, popListHeight) inView:rootView animated:YES];
    }
    else {
        [view showViewFromRect:CGRectMake(rootView.width - WCPOPLISTWIDTH, 64, WCPOPLISTWIDTH, popListHeight) inView:rootView animated:YES];
    }
}

#pragma mark - 显示调查问卷视图管理器方法
- (void)showAcvtViewController:(WSAcvtBean *)acvtBean {
    
    NSString *acvtCode = acvtBean.acvtCode;
    NSString *tipStr = nil;
    if ([acvtCode isEqualToString:@"storeAddtskf"]) { //新增
        NSArray *array = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type"] ArgumentsValue:@[STORE_UPDATE_FLAG]];
        WSBaseStoreOtherDataObject *obj = [array firstObject];
        tipStr = [NSString stringNotNilWithValue:obj.item2];
    }
    else if ([acvtCode isEqualToString:@"storeUpdatetskf"]) { //修改
        
        NSArray *array = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type"] ArgumentsValue:@[STORE_UPDATE_FLAG]];
        WSBaseStoreOtherDataObject *obj = [array firstObject];
        tipStr = [NSString stringNotNilWithValue:obj.item3];
    }

    [self jumpNewStoreVCWithAcvtBean:acvtBean tips:tipStr];
  
}
- (void)jumpNewStoreVCWithAcvtBean:(WSAcvtBean*)acvtBean tips:(NSString*)tipStr{
    if (tipStr && tipStr.length > 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"js_alert_title", nil) message:tipStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if ([acvtBean.publisher isEqualToString:@"1"]) {
        [self storeManageSearch:acvtBean];
        return;
    }
    
    LogInfo(@"Go into class WSAddNewStoreViewController");
    
    WSAddNewStoreViewController *l_newStoreVC = [[WSAddNewStoreViewController alloc] initWithFuncs:self.currentFuncs acvtBean:acvtBean storeBean:nil];
    l_newStoreVC.hidesBottomBarWhenPushed = YES;
    l_newStoreVC.title = ((acvtBean.acvtName.length > 0) ? acvtBean.acvtName : l_newStoreVC.title);
    if (!l_newStoreVC.currentVisitAction) {
        l_newStoreVC.currentVisitAction = self.currentVisitAction;
    }
    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:l_newStoreVC animated:YES];
    }
    else {
        [self.navigationController pushViewController:l_newStoreVC animated:YES];
    }
}
#pragma mark - 单元格点击编辑/修改操作执行方法
- (void)loadAcvtDis {
    
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:self.storeManageDataInfo.changeFlage forKey:@"changeFlage"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.refreshNodeName] forKey:@"objId"];
    [paramDic setObject:[NSString stringNotNilWithValue:@(self.storeManageDataInfo.acvtId)] forKey:@"extra_acvtId"];
    [paramDic setObject:[NSString stringNotNilWithValue:@(self.storeManageDataInfo.genId)] forKey:@"genId"];
    NSString *notifyID = @"loadAcvtDisManage";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAcvtDisUploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 单元格点击编辑/修改操作请求回调方法
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
       
        WSAcvtBean *acvtBean = nil;
        for (WSAcvtBean *acvt in self.addAcvtArray) {
            if ([acvt.acvtId integerValue] == self.storeManageDataInfo.acvtId) {
                acvtBean = acvt;
                continue;
            }
        }
        
        WSStoreBean *storeBean = [[WSStoreBean alloc] init];
        storeBean.Id = @"-1";
        storeBean.name = self.storeManageDataInfo.storeName;
        storeBean.addr = self.storeManageDataInfo.storeAddr;
        [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:dic genId:nil isRemoteSearch:NO];

        WSAcvtViewController *acvtController = [[WSAcvtViewController alloc] initWithAcvt:acvtBean Funcs:self.currentFuncs Store:storeBean
                                                                                      md5:[NSString stringNotNilWithValue:@(self.storeManageDataInfo.genId)] isFromRealTimeData:YES
                                                                                 SubEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        //acvtController.title = ((acvtBean.acvtName.length > 0) ? acvtBean.acvtName : acvtController.title);
        if (self.ownParentViewController) {
            [self.ownParentViewController.navigationController pushViewController:acvtController animated:YES];
        }
        else {
            [self.navigationController pushViewController:acvtController animated:YES];
        }
    }
}

#pragma mark - 单元格点击撤销操作执行方法
- (void)loadDeleteButton {
    
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.deleteButton] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:[NSString stringNotNilWithValue:@(self.storeManageDataInfo.genId)] forKey:@"recordId"];
    NSString *notifyID = @"deleteButton";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteButtonUploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 单元格点击撤销操作请求回调方法
- (void)deleteButtonUploadFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if ([notification.object isKindOfClass:[NSError class]]) {
        
        NSString *title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    [self loadStoreManage];
}

#pragma mark - 实现numberOfSectionsInTableView:协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.manageDataArray.count;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSStoreManageDataInfoModel *infoModel = self.manageDataArray[indexPath.row];
    CGFloat height = [WSStoreManageViewCell getStoreManageViewCellHeightWithModel:infoModel maxWidth:CGRectGetWidth(tableView.frame)];
    return height;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSStoreManageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoreManageCellId forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.model = self.manageDataArray[indexPath.row];
    cell.storeManageViewCellDelegate = self;
    return cell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 实现storeManageStatus:协议(表视图头部视图控件协议)
- (void)storeManageStatus:(NSInteger)status {
    
    [self.manageDataArray removeAllObjects];
    
    if (status == 10) {
        self.manageDataArray = [NSMutableArray arrayWithArray:self.manageModel.spestorelist];
    }
    else {
        for (WSStoreManageDataInfoModel *infoModel in self.manageModel.spestorelist) {
            if (infoModel.status == status) {
                [self.manageDataArray addObject:infoModel];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - 实现storeManageTimeStr:协议(表视图头部视图控件协议)
- (void)storeManageTimeStr:(NSString*)timeStr {
    
    self.timesStr = timeStr;
    [self loadStoreManage];
}

#pragma mark - 实现storeManageSearch:协议(表视图头部视图控件协议)
- (void)storeManageSearch:(WSAcvtBean *)acvtBean {
    
    WSStoreManageSearchViewController *searchManage = [[WSStoreManageSearchViewController alloc] init];
    searchManage.currentFuncs = self.currentFuncs;
    searchManage.currentAcvt = acvtBean;
    searchManage.hidesBottomBarWhenPushed = YES;

    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:searchManage animated:YES];
    }
    else {
        [self.navigationController pushViewController:searchManage animated:YES];
    }
}

#pragma mark - 实现popListView:didSelectedIndex:协议(导航栏右按键-多个问卷选择视图协议)
- (void)popListView:(WCPopListView *)popListView didSelectedIndex:(NSInteger)anIndex {
    
    [self showAcvtViewController:[self.addAcvtArray objectAtIndex:anIndex]];
}

#pragma mark - 实现btnDownStoreManageViewCell:andModel:协议(表视图单元格协议)
- (void)btnDownStoreManageViewCell:(NSInteger)btnTag andModel:(WSStoreManageDataInfoModel*)model {
    
    self.storeManageDataInfo = model;
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString * visitPrivacyPolicyFlag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];
    @weakify_self
    switch (btnTag) {
        case 0: { //编辑
            [self loadAcvtDis];
        }
            break;
        case 1: { //修改
            [self loadAcvtDis];
            
        }
            break;
        case 2: { //撤销
            [self loadDeleteButton];
        }
            break;
        default:
            break;
    }
}

@end
//========================================================================================================================================================================
