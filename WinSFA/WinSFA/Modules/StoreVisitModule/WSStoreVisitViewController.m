//
//  WSStoreVisitViewController.m
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStoreVisitViewController.h"
#import "WSBaseTableView.h"
#import "WSFuncsBean_opt.h"
#import "WSServiceDispatcher.h"
#import "WSInterAction.h"
#import "WSWorkFlowViewController.h"
#import "WSStoreInfoViewController.h"
#import "WSPfizerEtripModifyStoreInfoViewController.h"
#import "WSFunsShortCutData.h"
#import "WSFuncsBeanFilterLogicService.h"

@interface WSStoreVisitViewController (private)

-(void)processForLoadView:(WSInterAction *)interaction;

-(void)processForJumpToNextPage:(WSInterAction *)interaction;

@end


@implementation WSStoreVisitViewController

-(id)initWithFuncs:(WSFuncsBean *)funcs{
    
    self = [super initWithFuncs:funcs];
    
    shortCutArray = [self filterShortCutFuncsBean:funcs];
    if (self) {
        interaction_dict = [[NSMutableDictionary alloc] init];
        
        processfunction_dict =[[NSMutableDictionary alloc] init];
        
        servicedispatcher = [[WSServiceDispatcher alloc] init];
        
        [servicedispatcher setDispatcherDelegate:self];
        
        [processfunction_dict setValue:@"processForLoadView:" forKey:@"ws_service_query_for_store"];
        
        [processfunction_dict setValue:@"processForJumpToNextPage:" forKey:@"ws_service_jump_to_store"];
        
  
        
        return self;
    }
    
    return nil;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if(table_view!=nil){
        
        [self reloadData];
        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    table_view = [[WSBaseTableView alloc] initWithFrame:self.view.bounds];
    
    table_view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    table_view.delegate = self;
    table_view.shortCutArray = shortCutArray ;
    
    if ([self.currentFuncs.opt.showdetails isEqualToString:@"0"]) {
    
        [table_view setHiddendetail:YES];
    
    }
    
    [self.view addSubview:table_view];
    
    [self dataLoad];
}

-(void)dataLoad{
    
    WSInterAction *interaction  = [[WSInterAction alloc] init];
    
    [interaction setInner_id:@"ws_service_query_for_store"];
    
    [interaction setExecute_class:@"WSStoreService"];
    
    [interaction setExecute_method_param:interaction];
    
    [interaction setInner_param:self.currentFuncs];
    
    [interaction setExecute_method_ns:@"queryStoreListByFunc:"];
    
    [servicedispatcher executeDispatcher:interaction];
    
    [interaction_dict setObject:interaction forKey:[interaction inner_id]];
    
    
}
#pragma mark -
#pragma mark WSServiceDispatcherDelegate method

-(void)serviceInExecute:(WSInterAction *)interaction{
    
    
    
}

-(void)serviceBeginExecute:(WSInterAction *)interaction{
    

    
}

-(void)serviceExecuteEnd:(WSInterAction *)interaction{
    
    
    NSString  *process_func_sel_str = [processfunction_dict valueForKey:[interaction inner_id]];
    
    
    SEL   process_func_sel =  NSSelectorFromString(process_func_sel_str);
    
    if ([self respondsToSelector:process_func_sel]) {
        
        [self doDynamicCalling:self method:process_func_sel andParam:interaction];
        
    }
    
}

-(void)serviceExecuteEndWithError:(WSInterAction *)interaction{
    
    
 
}


#pragma mark -
#pragma mark WSWidgetDelegate method

-(void)executeAnyOperationWith:(WSInterAction *)interaction{
    
    [interaction setEnvValue:self.currentFuncs forKey:@"currentFuncs"];
    
    if (self.currentVisitAction) {
        
        [interaction setEnvValue:self.currentVisitAction  forKey:@"currentVisitAction"];
    
    }
    [interaction_dict setObject:interaction forKey:[interaction inner_id]];
    
    
    if([interaction direct_type]==0){
        
        
        SEL performselector = NSSelectorFromString((NSString *)[interaction execute_method_ns]);
        
        [self doDynamicCalling:self method:performselector andParam:interaction];
        
        
        return;
    }
    [servicedispatcher executeDispatcher:interaction];
    
}


-(void)processForLoadView:(WSInterAction *)interaction{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *datas = (NSMutableArray *)[interaction execute_result];
        
        [table_view loadContent:datas];
        
    });
    
}


-(void)processForJumpToNextPage:(WSInterAction *)interaction{
    
    
    WSWorkFlowViewController* wfvc = (WSWorkFlowViewController*)[interaction execute_result];
    
    if (self.ownParentViewController==nil) {
    
        [self.navigationController pushViewController:wfvc animated:YES];
   
    }else{

        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    
}

-(void)viewDetailInfo:(WSInterAction *)interaction{
 
    WSStoreBean  *storeBean = (WSStoreBean *)[interaction inner_param];
    
    
    UIViewController *storeInfo = nil;
    if ([self.currentFuncs.isStoreInfo isEqualToString:@"1"]) {
        storeInfo = [[WSStoreInfoViewController alloc] initWithStoreInfo:storeBean];
    }
    else if ([self.currentFuncs.isStoreInfo isEqualToString:@"3"])
    {
        storeInfo = [[WSPfizerEtripModifyStoreInfoViewController alloc] initWithFuncs:self.currentFuncs store:storeBean storeInfoDic:nil];
    }
    
    NSString *StoreInforString = NSLocalizedString(@"store_info",nil);
    
    storeInfo.title = StoreInforString;
    
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    
    if (self.ownParentViewController==nil) {
        
        [self.navigationController pushViewController:storeInfo animated:YES];
        
    }else{
        [self.ownParentViewController.navigationController pushViewController:storeInfo animated:YES];
    }
}



-(void)reloadData{
    
    dispatch_queue_t queue = dispatch_queue_create("storedata_loading", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{

            [self dataLoad];
    });
    

    
    
}

//过滤shortCut 的拜访项
- (NSArray *)filterShortCutFuncsBean:(WSFuncsBean *)currentFuncs{
    
    WSFuncsBean* subMenuFuncBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:currentFuncs];
    
    WSFunsShortCutData *data = [[WSFunsShortCutData alloc]init];
    
    NSArray *array = [[NSArray alloc]init];
    
    array = [data filterShortCutData:subMenuFuncBean];
    
    return array;
    
}


#pragma mark - 辉瑞零售详情快捷键
- (void)selectWithShortCutFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    
    
    UIViewController *viewController = [self nextPageWithFunsBean:bean withINdexStore:storeBean];
    [self gotoNextPageWithViewController:viewController withFuncsBean:bean withStoreBean:storeBean withAutoJump:YES];
    
}

@end
