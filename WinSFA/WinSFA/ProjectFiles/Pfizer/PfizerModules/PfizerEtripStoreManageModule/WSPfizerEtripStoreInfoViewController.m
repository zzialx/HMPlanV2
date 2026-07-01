//
//  WSPfizerEtripStoreInfoViewController.m
//  WinSFA
//
//  Created by yang on 14-5-9.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPfizerEtripStoreInfoViewController.h"
#import "WSStoreInfoViewController.h"
#import "WSRequestHelper.h"
#import "WSAcvtListViewController.h"
#import "WSAcvtViewController.h"
#import "WSPfizerEtripModifyStoreInfoViewController.h"

@interface WSPfizerEtripStoreInfoViewController ()

@end

@implementation WSPfizerEtripStoreInfoViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSStoreBean *l_store = [self.showStoreArray objectAtIndex:indexPath.row];
    self.currentStore = l_store;
    
    WSPfizerEtripModifyStoreInfoViewController *controller = [[WSPfizerEtripModifyStoreInfoViewController alloc] initWithFuncs:self.currentFuncs store:self.currentStore storeInfoDic:nil];
    
    // action应该是和当前选中的store相关
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentStore.Id;
    action.func_code = self.currentFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = self.currentFuncs.name;
    //暂不需要
//    if (self.currentVisitAction
//        && self.currentVisitAction.module_fc
//        && [self.currentVisitAction.module_fc length] > 0) {
//        
//        action.module_fc = self.currentVisitAction.module_fc;
//    }else{
//        
//        action.module_fc = action.func_code;
//    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    controller.currentVisitAction = action;
    
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParentViewController.navigationController pushViewController:controller animated:YES];
    
}

@end
