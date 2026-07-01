//
//  WSPersonnelListTreeController.m
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPersonnelListTreeController.h"
#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "WSVisitStoreActionTable.h"
#import "WSPersonnelListTreeView.h"
#import "WSNewStoreListViewController.h"
#import "WSSubempstoreBeanArray.h"
#import "BaseViewController.h"
#import "WSSpecialAcvtViewController.h"
#import "WSCustomerQueryViewController.h"
#import "WSAcvtViewController.h"
#import "WSAcvtListViewController.h"
#import "WSBaseAcvtDBService.h"

@implementation WSPersonnelListTreeController

- (id)initWithFuncs:(WSFuncsBean *)funcs{
    
    self.currentFuncs = funcs ;
    
    self.dataArray = [[NSMutableArray alloc]init];
    
    [self initDataArray];
    
    
    WSPersonnelListTreeView *treeView = [[WSPersonnelListTreeView alloc]initWithFrame:self.view.bounds withFuncsBean:self.currentFuncs];
    treeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    treeView.dataArray = self.dataArray ;
    
    [treeView reloadDataForDisplayArray];
    
    treeView.delegate = self;
    
    [self.view addSubview:treeView];
    
    return self;
    
}

- (void)initDataArray{
    
    WSSubempstoreBeanArray *subempstoreArray = [WSAppData getObjectbyKey:self.currentFuncs.filter];
    
    for (WSSubempstoreBean *subempStoreBean in subempstoreArray.subempstoreArray) {
        
        //寻找ROOT节点
        if (subempStoreBean.parentId == nil) {
            
            subempStoreBean.sub_level_code = @"3";
            
            [self.dataArray addObject:subempStoreBean];
            
            for (WSSubempstoreBean *subempStoreBean1 in subempstoreArray.subempstoreArray) {
                //寻找第二级节点
                NSString *parentId = subempStoreBean.Id;
                if (!parentId) {
                    parentId = subempStoreBean.orgId;
                }
                if ([subempStoreBean1.parentId isEqualToString:parentId]) {
                    
                    subempStoreBean1.sub_level_code = @"4";
                   //父节点中是否包含了子节点
                    if (![subempStoreBean.sonBean containsObject:subempStoreBean1]) {
                        
                        [subempStoreBean.sonBean addObject:subempStoreBean1];
                        
                        for (WSSubempstoreBean *subempStoreBean2 in subempstoreArray.subempstoreArray ) {
                            //寻找第三级节点
                            NSString *parentId = subempStoreBean1.Id;
                            if (!parentId) {
                                parentId = subempStoreBean1.orgId;
                            }
                            if ([subempStoreBean2.parentId isEqualToString:parentId]) {
                                
                                subempStoreBean2.sub_level_code =@"5";
                                
                                if (![subempStoreBean1.sonBean containsObject:subempStoreBean2]) {
                                    
                                    [subempStoreBean1.sonBean addObject:subempStoreBean2];
                                }
                            }
                        }
                        
                   }
                    
                }
            }
        }
    }
    
    
}

- (void)personnelListTreeView:(WSPersonnelListTreeView *)personnelListTreeView withSubempStoreBean:(NSObject<I_W_Cell> *)dataItem{
    
    if ([dataItem isKindOfClass:[WSSubempstoreBean class]]) {
        WSSubempstoreBean *subempStoreBean = (WSSubempstoreBean *)dataItem;
        //空岗的人员不能点击进入
        if (!subempStoreBean.Id) {
            return;
        }
        
        
        UIViewController *pushVC = nil;
        
        WSFuncsBean *fb = [self.currentFuncs.funcsArray objectAtIndex:0];
        
        Class aClass = NSClassFromString([WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName]);
        
        BaseViewController *vc  = nil ;
        
        
        if (self.currentFuncs.funcsArray.count > 0) {
            WSWorkFlowViewController *workFlow = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:nil subEmpStore:subempStoreBean];
            vc =(BaseViewController *)workFlow;
        }else if ([aClass instanceMethodForSelector:@selector(initWithFuncs:Store:)]) {
            vc = [[aClass alloc] initWithFuncs:fb Store:self.currentStore];
        }
        else{
            vc =[[aClass alloc]initWithFuncs:fb];
        }
        
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            [(WSSpecialAcvtViewController *)vc setSubempid:subempStoreBean.Id];
        }
        else if ([vc isKindOfClass:[WSNewStoreListViewController class]]){
            [(WSNewStoreListViewController *)vc setSubempid:subempStoreBean.Id];
        }
        if ([vc isKindOfClass:[WSCustomerQueryViewController class]]) {
            [(WSCustomerQueryViewController *)vc setSubempid:subempStoreBean.Id];
        }
        
        if (vc == nil) {
            if ([fb.isAcvtList isEqualToString:@"1"]) {
                
                WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                NSArray *filterArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:fb.filter];
                
                WSAcvtBean *l_acvtBean = nil ;
                
                if ([filterArray count] > 0) {
                    l_acvtBean  =[ filterArray objectAtIndex:0];
                    
                    vc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs:fb Store:self.currentStore];
                }
                else{
                    
                    vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName])alloc]initWithFuncs:fb];
                    
                    if ([vc isKindOfClass:[WSAcvtListViewController class]]) {
                        
                        WSAcvtListViewController *listvc =(WSAcvtListViewController *)vc;
                        listvc.m_SubempstoreBean  = subempStoreBean ;
                        
                    }
                }
            }
        }
        
        // SFA-17460 
        vc.title = [dataItem getName];
        
        pushVC = vc ;
        
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc]init];
        
        action.parent_action_id = self.currentVisitAction.ID ;
        
        action.store_id = subempStoreBean.Id ;
        
        action.func_code = self.currentFuncs.fc;
        
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        
        if (self.currentVisitAction
            
            && self.currentVisitAction.module_fc
            
            && [self.currentVisitAction.module_fc length] > 0) {
            
            action.module_fc = self.currentVisitAction.module_fc;
            
        }else{
            
            action.module_fc = action.func_code;
            
        }
        
        
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        
        action.title = subempStoreBean.name;
        
        pushVC.currentVisitAction = action;
        
        pushVC.showActionTip = YES;
        
        
        [self.navigationController pushViewController:pushVC animated:YES];

    }
}

@end
