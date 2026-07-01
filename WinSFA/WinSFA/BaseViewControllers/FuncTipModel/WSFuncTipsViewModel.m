//
//  WSFuncTipsViewModel.m
//  WinSFA
//
//  Created by yuanji on 2025/4/18.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSFuncTipsViewModel.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSRequestHelper.h"
#import "WSFuncTipsViewModel.h"
#import "WSFuncTipsModel.h"
#import "WSFuncTipAlertView.h"
#import "YYModel.h"

@implementation WSFuncTipsViewModel

#pragma mark - 是否显示审批弹窗方法
+ (BOOL)isShowTipsView {
    
    NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *key = [NSString stringWithFormat:@"%@_%@", ISNULL(empId), @"functips"];
    
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!value) {
        return YES;
    }
    
    NSInteger day_difference = [WSCurrentTime differencewithDate:value withDate:bizdate];
    if (day_difference > 0) {
        return YES;
    }

    return NO;
}

#pragma mark - 获取用户角色方法
+ (NSString *)getLoginUserRole {
    
    NSString *sql = @"select base_store_acvt_dis.acvt_qst_answer from base_store_acvt_dis join base_acvt_qst on base_acvt_qst.acvtId = base_store_acvt_dis.acvtId and base_acvt_qst.acvtQstId = base_store_acvt_dis.acvtQstId where 1=1 and base_acvt_qst.qstCod = 'wt_selectrole'";
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
    WSBaseStoreAcvtDisObject *obj = [dataArray firstObject];
    NSString *role = obj.acvt_qst_answer;
    return role;
}

#pragma mark - 获取标题方法
+ (NSString *)getTipsTitle {
    
    NSString *role = [WSFuncTipsViewModel getLoginUserRole];
    if ([role isEqualToString:@"销售代表"]) {
        return @"审批结果通知";
    }
    if ([role isEqualToString:@"主管"]) {
        return @"未审批内容提醒";
    }
    return @"提醒";
}

#pragma mark - 保存读取状态方法
+ (void)saveTipsReadStatus {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    [[NSUserDefaults standardUserDefaults] setObject:bizdate forKey:[NSString stringWithFormat:@"%@_%@", ISNULL(empId), @"functips"]];
}

#pragma mark - 显示提醒弹窗方法
+ (void)showTipsViewWithRole:(WSShowFuncTipsViewRoleType)roleType {
    
    LogInfo(@"WSFuncTipsViewModel showTipsViewWithRole 审批弹框 进入检索逻辑");
    
    if (roleType == WSShowFuncTipsViewRoleTypeSale) {
            
        NSString *userRoleStr = [WSFuncTipsViewModel getLoginUserRole];
        if (![userRoleStr isEqualToString:@"销售代表"]) {
            
            LogInfo(@"WSFuncTipsViewModel showTipsViewWithRole 角色不对 不是销售代表");
            return;
        }
    }
    else if (roleType == WSShowFuncTipsViewRoleTypeManager) {
        
        NSString *userRoleStr = [WSFuncTipsViewModel getLoginUserRole];
        if (![userRoleStr isEqualToString:@"主管"]) {
            
            LogInfo(@"WSFuncTipsViewModel showTipsViewWithRole 角色不对 不是销售主管");
            return;
        }
    }
    
    if (![WSFuncTipsViewModel isShowTipsView]) {
        
        LogInfo(@"WSFuncTipsViewModel showTipsViewWithRole 今天已经显示过弹框 每天只显示一次弹框");
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:nil tapTarget:self action:nil];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"funcTip" forKey:@"objId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"bizDate"];
    
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSDictionary *resultDic = [response jsonResponse];
        WSFuncTipsList *model = [WSFuncTipsList yy_modelWithDictionary:resultDic];
        [WSFuncTipsViewModel addFuncTipAlertViewWithFuncTipList:model];
    }
                                                      failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:response.error.titleForError tips:nil tapTarget:nil action:nil
                                 type:MBProgressHUDMessageTypeFailed];
    }];
}

#pragma mark - 添加审批提醒框方法
+ (void)addFuncTipAlertViewWithFuncTipList:(WSFuncTipsList *)funcTipModel {
    
    if (!funcTipModel || funcTipModel.funcTip.count == 0) {
        
        LogInfo(@"WSFuncTipsViewModel addFuncTipAlertViewWithFuncTipList 提醒无数据");
        return;
    }
    
    NSMutableArray *filterList = [[NSMutableArray alloc] init];
    for (int i = 0; i < funcTipModel.funcTip.count; i++) {
        
        id funcItem = [funcTipModel.funcTip objectAtIndex:i];
        if ([funcItem isKindOfClass:[WSFuncTipsModel class]]) {
            
            WSFuncTipsModel *model = (WSFuncTipsModel *)funcItem;
            if ([model.isShow isEqualToString:@"1"]) {
                [filterList addObject:model];
            }
        }
    }
    if (filterList.count == 0) {
        
        LogInfo(@"WSFuncTipsViewModel addFuncTipAlertViewWithFuncTipList 筛选提醒数据源后无数据");
        return;
    }
    
    NSString *title = [WSFuncTipsViewModel getTipsTitle];
    WSFuncTipAlertView *funcTipView = [WSFuncTipAlertView creatFuncTipAlertViewWithList:filterList title:title];
    funcTipView.completeBlock = ^(WSFuncTipAlertView *view) {
    
        [WSFuncTipsViewModel saveTipsReadStatus];
        [view closeFuncTipAlertView];
    };
}

@end
