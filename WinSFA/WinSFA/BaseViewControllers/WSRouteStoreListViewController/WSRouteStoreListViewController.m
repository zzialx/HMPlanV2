//
//  WSRouteStoreListViewController.m
//  WinSFA
//
//  Created by admin on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSRouteStoreListViewController.h"
#import "WSRouteStoreViewModel.h"
#import "WSRouteStoreTableViewCell.h"
#import "WSBaseStoreDBService.h"
#import "WSFuncsBeanArray.h"
#import "WSFuncsBean.h"
#import "MJRefresh.h"
#import "WSTskfRouteModel.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "NSArray+SQL.h"

#define Page_Size 50

static NSString * const kRouteCellID = @"routeCellID";
//============================================================================================================================================================================

@interface WSRouteStoreListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WSRouteStoreViewModel *viewModel;
@property (nonatomic, strong) NSArray *storeList;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, strong) NSMutableDictionary *foldStateDic;

@end
//============================================================================================================================================================================

@implementation WSRouteStoreListViewController

#pragma mark - 获取tableView方法
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
        }];
        
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 240.0f;
        _tableView.tableFooterView= [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[WSRouteStoreTableViewCell class] forCellReuseIdentifier:kRouteCellID];
    }
    
    return _tableView;
}

#pragma mark - 获取viewModel方法
- (WSRouteStoreViewModel *)viewModel {
    
    if (!_viewModel) {
        
        _viewModel = [[WSRouteStoreViewModel alloc] init];
    }
    return _viewModel;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = self.currentFuncs.name.length > 0 ? self.currentFuncs.name : @"门店列表";
    
    self.foldStateDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (self.isRequestStoreList) {
        [self p_getTSRoleStoreList];
    }
    else {
        [self p_getStoreList];
    }
    
    [self tableView];
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.storeList.count;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    WSRouteStoreTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kRouteCellID];
    if (!cell) {
        cell = [[WSRouteStoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRouteCellID];
    }
    
    WSStoreBean *storeBean = self.storeList[indexPath.row];
    [cell setStore:storeBean withOpt:self.currentFuncs.opt foldState:self.foldStateDic[storeBean.Id]];

    @weakify_self;
    [cell setShowStoreAgreementAction:^(WSStoreBean *cellStoreBean, BOOL isExpend, WSRouteStoreTableViewCell *cell) {
        
        @strongify_self;
        [self.foldStateDic setObject:(isExpend ? @"1" : @"0") forKey:cellStoreBean.Id];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    return cell;
}

#pragma mark - 请求门店列表方法
- (void)p_getTSRoleStoreList {
    
    @weakify_self;
    [self querying_messageTips];
    
    [self.viewModel requestStoreListWithRequestObjId:@"getMySpeRouteStore" docDate:self.docDate sucess:^(NSArray<WSStoreBean *> * _Nonnull list) {
        
        @strongify_self;
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        if (list.count > 0) {
            [self p_getStoreList];
        }
    }
                                             failure:^(NSString * _Nonnull tips) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        [MBProgressHUD showHUDAddedTo:self.view withText:tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }];
}

#pragma mark - 设置门店列表方法
- (void)p_getStoreList {
    
    NSString *search_objId = STORES;
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *routeID = @"2";
    NSDictionary *otherDic = @{kStoreDBOtherData_isFollowStore : [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore],
                               kStoreDBOtherData_storeClassCondition : [self getStoreClassFilterCondition],
                               kStoreDBOtherData_visitTimeSort : [NSString stringNotNilWithValue:self.currentFuncs.opt.visitTimeSort],
                               kStoreDBOtherData_RouteID : routeID,
                               kStoreDBOtherData_RouteID_Value : self.isRequestStoreList?ISNULL(self.docDate):ISNULL(self.selectRouteId)};
    
    self.storeList = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:@"" empId:empId styp:@"" searchStr:@"" search_objId:search_objId isSearchable:NO
                                                                     storeAccessMode:WSStoreAccessModeNormal acvtId:nil selectedQstValues:nil rangeConditions:nil
                                                                            distance:0 pageNumber:-1 distanceSort:self.currentFuncs.opt.distancesSort
                                                                        otherDataDic:otherDic parentStoreFc:nil];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString *routeVisitStateSql = [NSString stringWithFormat:@"select * from base_store_other_data bsod where bsod.item1 = '%@' and bsod.type = '%@'",
                                    self.selectRouteId, VISIT_PLAN_ROUTE];
    NSArray *routeVisitStateArray = [sqliteUtil queryAndReturnInfosBySql:routeVisitStateSql andClassName:@"WSBaseStoreOtherDataObject"];
    
    for (WSStoreBean *store in self.storeList) {
        
        if (store.Id) {
            
            [self.foldStateDic setObject:@"0" forKey:store.Id];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"store_id == %@", store.Id];
            NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[routeVisitStateArray filteredArrayUsingPredicate:predicate]];
            WSBaseStoreOtherDataObject *storeOtherDataObj = [resultArray firstObject];
            if (storeOtherDataObj) {
                store.routeVisitState = [storeOtherDataObj.item2 isEqualToString:@"1"] ? @"路线内已访" : nil;
            }
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - 获取门店筛选条件方法
- (NSString *)getStoreClassFilterCondition {
    
    if ([self.currentFuncs.opt.addFilterType length]  == 0) {
        return @"";
    }
    
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean_qst *qst = [acvtService queryQstWithAcvtQstCode:@"storeClass"];
    if (!qst) {
        return @"";
    }
    
    WSBaseAcvtdisDBService *acvtDisService = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *dataArray = [acvtDisService queryStoreIdWithAnswer:self.currentFuncs.opt.addFilterType acvtQstID:qst.acvtQstId];
    if ([dataArray count] == 0) {
        return @"";
    }
    
    NSString *sql = [NSString stringWithFormat:@" and store.store_Id %@ ", [dataArray getInSqlString]];
    return sql;
}

@end
//============================================================================================================================================================================
