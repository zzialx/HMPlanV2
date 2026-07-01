//
//  WSNewStoreVisitViewController.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-22.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSNewStoreVisitViewController.h"
#import "WSAddNewStoreViewController.h"
#import "WSWorkFlowViewController.h"
#import "WSVisitStoreActionTable.h"
#import "WSAcvtListDataItem.h"
#import "WSFuncsBeanFilterLogicService.h"

@interface WSNewStoreVisitViewController ()

@property (nonatomic, strong) WSAcvtListDataItem *acvtItem;

@end

@implementation WSNewStoreVisitViewController

- (id)initWithFuncs:(WSFuncsBean*)funcs acvtListItem:(WSAcvtListDataItem *)item
{
    self = [super initWithFuncs:funcs];
    if (self) {
        self.acvtItem = item;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newstoreChange:) name:newStoreNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:newStoreNotification object:nil];
}

- (void)newstoreChange:(id)sender {
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
    
//    NSArray* array=[[WSAddStoreTable sharedTable] queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID"] ArgumentsValue:@[[WSCurrentTime getDateString],@"1",[WSAppData getObjectbyKey: APPDATA_EMPID]]];
//
//    if (self.addStore) {
//        NSString *storeId =self.addStore.store_id ;
//        for (WSAddStoreObject *store in array) {
//            NSString *checkId = store.store_id;
//            if ([checkId isEqualToString:storeId]) {
//                self.addStore = store;
//                break;
//            }
//        }
//    }
}

- (UIView *)getTableHeaderView {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"WSNewStoreVisitCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *title = nil;
    if ([indexPath row] == 0) {
        title = NSLocalizedString(@"modify_store", nil);
    } else {
        title = NSLocalizedString(@"visit_store",nil);
    }
    cell.textLabel.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath row] == 0) {


        WSAddNewStoreViewController *ansVC = [[WSAddNewStoreViewController alloc] initWithFuncs:self.currentFuncs acvtId:self.acvtItem.acvtID genId:self.acvtItem.genID newStoreId:self.acvtItem.newstoreid];
        LogInfo(@"Going to class WSAddNewStoreViewController");
        if (self.ownParentViewController.navigationController) {
            [self.ownParentViewController.navigationController pushViewController:ansVC animated:YES];
        } else if (self.navigationController) {
            [self.navigationController pushViewController:ansVC animated:YES];
        }
    } else {
        
        WSStoreBean *store = [[WSStoreBean alloc] init];
        store.Id = self.acvtItem.newstoreid;
        store.name = self.acvtItem.mainTitle;
//        store.mappingStoreListFV = self.addStore.func_view;
//        store.mappingStoreListFC = self.addStore.func_code;
        BOOL haveStoreNotLeave = NO;
        
        if (store.plan) {
            haveStoreNotLeave = ![self anyStoreHasNotLeave:store andModuleFC:self.inPlanFuncsBean.fc];
        }else{
            haveStoreNotLeave = ![self anyStoreHasNotLeave:store andModuleFC:self.currentFuncs.fc];
        }
        
        if(haveStoreNotLeave)
            return;
        self.currentStore = store;
        [self startUpdata:store];
    }
}

- (void)goNextWorkView {
    
    WSWorkFlowViewController *wfvc = nil;
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
    if (subMenuFB.funcsArray.count == 1) {
        subMenuFB = [subMenuFB.funcsArray firstObject];
        [self selectListTableViewCell:nil withSlectFunsbean:subMenuFB withStoreBean:self.currentStore];
        return;
    }
    if(subMenuFB == nil){
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:self.currentFuncs Store:self.currentStore];
    }
    else {
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:subMenuFB Store:self.currentStore];
    }
    
    // Add title
    wfvc.title = self.currentStore.name;
    
    //设置访问节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentStore.Id;
    action.func_code = self.currentFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = self.currentFuncs.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    wfvc.currentVisitAction = action;
    wfvc.moduleFC = action.module_fc;
    
    if (self.ownParentViewController) {
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    } else if (self.navigationController) {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}
@end
