//
//  WSSubStoreListViewController.m
//  WinSFA
//
//  Created by yang on 14-5-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSubStoreListViewController.h"
#import "WCOptionalSource.h"
#import "WSRequestHelper.h"
#import "WSVisitStoreActionTable.h"
#import "WSWorkFlowViewController.h"
#import "WSFuncsBeanFilterLogicService.h"

#define GET_STORE_LIST_NOTIFY @"GET_STORE_LIST_NOTIFY"

@interface WSSubStoreListViewController ()

@end

@implementation WSSubStoreListViewController

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self)
    {
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:funcs.fv];
        self.currentFuncs = funcs;
        self.title = funcs.name;
        NSMutableArray* array = [[NSMutableArray alloc]init];
        self.storeArray = array;
        self.filterArray = [[NSMutableArray alloc]init];
        
        return self;
        
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    self = [self initWithFuncs:funcs];
    
    if (self) {
        self.parentStoreBean = store;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startGetStoreList];
}

- (void)initDataArray
{
    
}

- (void)startGetStoreList
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getStoreListFinished:)
                                                 name:GET_STORE_LIST_NOTIFY
                                               object:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"1" forKey:@"compress"];
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (empId) {
        [dic setObject:empId forKey:@"empId"];
    }
    if (self.currentFuncs.filter) {
        [dic setObject:self.currentFuncs.filter forKey:@"objId"];
    }
    
    [dic setObject:@"no cellid" forKey:@"cellId"];
    if (self.parentStoreBean.Id) {
        [dic setObject:self.parentStoreBean.Id forKey:@"storeId"];
    }
    [[WSRequestHelper shareInstance] uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:GET_STORE_LIST_NOTIFY md5:nil isUpload:NO];
    

    [self querying_messageTips];

}

- (void)getStoreListFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GET_STORE_LIST_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        
       
        NSDictionary *uploadState = [info objectFromJSONString];
        
        NSArray *array = nil;
        
        if (self.currentFuncs.filter) {
            array = [uploadState objectForKey:self.currentFuncs.filter];
        }
        
        self.storeArray = [NSMutableArray array];
        if (array && [array count] > 0) {
            for (NSDictionary *storeDic in array) {
                WSStoreBean *storeBean = [[WSStoreBean alloc] initStoreWithObject:storeDic IsPlan:NO];
                [self.storeArray addObject:storeBean];
            }
        }
        
        self.storeArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:self.storeArray]];
        self.filterArray = [NSMutableArray arrayWithArray:self.storeArray];
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];

        [self.tableView reloadData];
    }
}

- (void)startUpdata:(WSStoreBean *)store
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY
                                               object:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"1" forKey:@"compress"];
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (empId) {
        [dic setObject:empId forKey:@"empId"];
    }
    [dic setObject:@"childstoreotherinfoontime" forKey:@"objId"];
    if (self.currentStore.Id) {
        [dic setObject:self.currentStore.Id forKey:@"storeId"];
    }
    [[WSRequestHelper shareInstance] uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:UPDATA_NOTIFY md5:nil isUpload:NO];
    
    [self querying_messageTips];

}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATA_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        
        NSDictionary *uploadState = [info objectFromJSONString];
        if(self.currentStore != nil)
            [self.currentStore reSetStore:uploadState Key:@"childstoreotherinfoontime"];
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        [self goNextWorkView];
    }
    
}

-(void)goNextWorkView
{
    //以下code因submenu而改
    if ([self.currentFuncs.funcsArray count]<1) {
        return;
    }
    
    WSWorkFlowViewController* wfvc = nil;

    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
    if (subMenuFB.funcsArray.count == 1) {
        subMenuFB = [subMenuFB.funcsArray firstObject];
        [self selectListTableViewCell:nil withSlectFunsbean:subMenuFB withStoreBean:self.currentStore];
        return;
    }
    if(subMenuFB==nil){
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:self.currentFuncs Store:self.currentStore];
    }
    else {
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:subMenuFB Store:self.currentStore];
    }
    
    // Add UIViewController
    if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
        wfvc.title = self.currentStore.name;
    }
    
    //设置访问节点
    if (self.currentVisitAction) {
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
        action.ID = (int)[[WSVisitStoreActionTable sharedTable] queryActionId:action];
        wfvc.currentVisitAction = action;
        wfvc.moduleFC = action.module_fc;
    }

    if (self.ownParentViewController) {
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    } else {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}
@end
