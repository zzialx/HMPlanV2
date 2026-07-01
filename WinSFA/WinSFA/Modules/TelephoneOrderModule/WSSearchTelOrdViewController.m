//
//  SearchTelOrdViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSearchTelOrdViewController.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSMV_LISTViewController.h"
#import "WSInPlanStoreBean.h"
#import "WSOutPlanStoreBean.h"
#import "WSAcvtViewController.h"
#import "WSVisitStoreActionTable.h"

@implementation WSSearchTelOrdViewController


-(void)goNextWorkView
{
    //以下code因submenu而改
    
    if([self.currentFuncs.funcsArray count] < 1)
        return;
    
    WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:0];
    
    WSMV_LISTViewController* ml = [[WSMV_LISTViewController alloc] initWithFuncs:fb Store:self.currentStore];
    
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
    ml.currentVisitAction = action;
    
    if (fb && fb.funcsArray && [fb.funcsArray count] == 1) {
        [ml initData];
        UIViewController *nextViewController = [ml generateNextPageWithRow:0];
        if (nextViewController) {
            self.hidesBottomBarWhenPushed = YES;
            [self.ownParentViewController.navigationController pushViewController:nextViewController animated:YES];
        }
    }else {
        self.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:ml animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSStoreBean* store = [self.filterArray objectAtIndex:indexPath.row];
    if(![self anyStoreHasNotLeave:store andModuleFC:self.currentFuncs.fc])
        return;
    self.currentStore = store;
    
    [self startUpdata:store];

}
@end
