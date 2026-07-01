//
//  WSMainNoticeView.m
//  WinSFA
//
//  Created by Alicia on 2017/3/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSMainNoticeView.h"
#import "WSFuncsBean.h"
#import "WSBaseStoreDBService.h"
#import "WSWorkFlowViewController.h"
#import "WSSubempstoreBeanArray.h"
#import "WSNextStepFuncsViewController.h"

#define kFC_TAB_V2001   @"TAB_V2001"

@interface WSMainNoticeView ()

@property (nonatomic, strong) WSInoutStoreObject *store;
@property (nonatomic, strong) WSSubempstoreBean *subempStore;

@end

@implementation WSMainNoticeView

#pragma mark - Public Method
- (void)setNotLeaveStore:(WSInoutStoreObject *)store {
    self.store = store;
    
    NSString *tips = NSLocalizedString(@"calling_on_pos_need_exit_prompt", nil);
    NSString *notice = [NSString stringWithFormat:@"%@%@", store.memo1, tips];
    [self setNoticeText:notice];
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTOMATIC_DEPARTURE object:nil userInfo:nil];

}

#pragma mark - Actions
- (void)viewTapAction:(UITapGestureRecognizer *)tapRecognizer {
    NSArray *storesArray  = [self getAllStores];
    if ([storesArray count] == 0) {
        return;
    }
    WSStoreBean *storeBean = [storesArray firstObject];
    storeBean.plan = [self.store.is_planed isEqualToString:@"1"] ? YES : NO;
    
    //判断是否是随访的店
    if (![storeBean.empId isEqualToString:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]]) {
        WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:SUBEMPSTORES];
        self.subempStore = [subBeanArr getSubempstoreById:storeBean.empId];
    }

    [self goNextWorkView:storeBean];
}


- (void)goNextWorkView:(WSStoreBean *)storeBean {
    NSString *modulefc = self.store.modulefc;
    
    WSFuncsBeanArray* fba= [WSAppData getObjectbyKey:FUNCS];
    
    WSFuncsBean *currectFunc = [fba getFuncsBeanFromAllFucsWithFC:modulefc];
    if (!currectFunc) {
        LogError(@"Can not find the current func");
        return;
    }
    if (![currectFunc.fv isEqualToString:kFC_TAB_V2001] && currectFunc.funcsArray && currectFunc.funcsArray.count == 1) {
        WSFuncsBean *nextFuncsBean = currectFunc.funcsArray[0];
        
        //兼容三棵树部分升级时老配置,多一层TAB_V11001
        if ([nextFuncsBean.fv isEqualToString:currectFunc.fv] && nextFuncsBean.funcsArray.count == 1) {
            nextFuncsBean = [nextFuncsBean.funcsArray firstObject];
        }
        
        if ([nextFuncsBean.fv isEqualToString:FV_TAB_V21001]) {
            
            WSFuncsBean* subMenuFB = nil;
            if ([nextFuncsBean.submenu length] > 0) {
                subMenuFB = [fba getFuncsBeanFromSubFC:nextFuncsBean.submenu];
            }
            if (subMenuFB) {
                currectFunc = subMenuFB;
            }else {
                currectFunc = currectFunc.funcsArray[0];
            }
            
        }
    }
    
    //设置访问节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.store_id = self.store.store_id;
    action.func_code = self.store.func_code;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = currectFunc.name;
    action.module_fc =  modulefc;
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    //MN-1009 2018-03-07
    BOOL isNextStep = [currectFunc.opt.isIntentToStore isEqualToString:@"navigation"];
    if ((currectFunc.readonly && currectFunc.iParentFuncsBean.funcsArray.count == 1) || !isNextStep)
    {
        WSWorkFlowViewController *wfvc = nil;
        if (self.subempStore && [self.subempStore.Id length] > 0) {
            wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:currectFunc Store:storeBean subEmpStore:self.subempStore];
        }else{
            wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:currectFunc Store:storeBean];
        }
        
        wfvc.title = self.store.memo1;
        wfvc.currentVisitAction = action;
        wfvc.moduleFC = action.module_fc;
        wfvc.hidesBottomBarWhenPushed = YES;
        
        [[[self viewController] navigationController] pushViewController:wfvc animated:YES];
    }
    else
    {
        WSNextStepFuncsViewController *vc = [[WSNextStepFuncsViewController alloc] initWithFuncs:currectFunc store:storeBean subempStore:self.subempStore
                                                                                    acvtNewStore:nil moduleFC:action.module_fc];
        vc.title = self.store.memo1;
        vc.currentVisitAction = action;
        vc.isTabMode = YES;
        vc.hidesBottomBarWhenPushed = YES;
        [[[self viewController] navigationController] pushViewController:vc animated:YES];
    }
}

//获取所有门店数据
- (NSArray *)getAllStores {
    WSBaseStoreDBService *storeService = [[WSBaseStoreDBService alloc] init];
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    if ([self.store.sr_id length] > 0 && ![self.store.sr_id isEqualToString:@"null"]) {
        empId = self.store.sr_id;
    }
    
    NSArray *storesArray = [storeService queryStoreWithId:self.store.store_id andEmpId:empId];
    if ([storesArray count] == 0) {
        LogError(@"Can not find the storeId %@ empId %@", self.store.store_id, empId);
    }
    return  storesArray;
    
}
@end
