//
//  WSWebViewNativeBridgeManager.m
//  WinSFA
//
//  Created by yang on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSWebViewNativeBridgeManager.h"
#import "WSFuncsBeanArray.h"
#import "WCBaseViewController.h"
#import "WSAcvtHttpService.h"
#import "WSAcvtViewController.h"
#import "WSStoreBeans.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSBaseMsgTypeTable.h"
#import "WSDetalViewController.h"
#import "WSGetMsgHttpService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreDBService.h"
#import "WCBaseViewController.h"
#import "WSSubEmpMapViewController.h"
#import "WSInoutStoreTable.h"
#import "WSMainLeftViewManager.h"
#import "WSStoreHttpService.h"
#import "WSWorkFlowViewController.h"
#import "WSStoreDataProcessService.h"
@interface WSWebViewNativeBridgeManager ()

@property (nonatomic, strong) WSAcvtHttpService *service;
@property (nonatomic, strong) WSGetMsgHttpService *getMsgHttpService;
@property (nonatomic, strong) WSStoreHttpService *getStoreDataService;

@property (nonatomic, copy) NSString *funcsCode;
@property (nonatomic, copy) NSString *storeID;
@property (nonatomic, copy) NSString *acvtID;
@property (nonatomic, copy) NSString *genID;
@property (nonatomic, copy) NSString *objID;
@property (nonatomic, copy) NSString *empID;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *sub_store_emp_id;
@property (nonatomic, copy) NSString *orderNo;
@property (nonatomic, copy) NSString *pagetype;
@property (nonatomic, copy) NSString *nolnstallMsg;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *route_id; // SFA-13481 路线id
@property (nonatomic, copy) NSString *date_extra; // MMSH-2582 日期
@property (nonatomic, copy) NSString *srid_extra; // MMSH-2675 下属id


@end

@implementation WSWebViewNativeBridgeManager


- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}


- (void)processParameters:(NSURL *)url
{
    //获取参数
    NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
    
    for (NSString *queryStr in queryArray) {
        NSArray *parasArray = [queryStr componentsSeparatedByString:@"="];
        NSString *paraName = [parasArray firstObject];
        NSString *paraValue = nil;
        if ([parasArray count] > 1) {
            paraValue = [parasArray objectAtIndex:1];
        }
        
        if ([paraName isEqualToString:@"fc_extra"]) {
            self.funcsCode = paraValue;
        }else if ([paraName isEqualToString:@"pos_id_extra"]){
            self.storeID = paraValue;
        }else if ([paraName isEqualToString:@"pos_name_extra"]){
            // 门店 ID, iOS 咱不需要所以暂时不需要实现
        }else if ([paraName isEqualToString:@"extra_acvtId"]){
            self.acvtID = paraValue;
        }else if ([paraName isEqualToString:@"dynamic_gen_id_extra"]){
            self.genID = paraValue;
        }else if ([paraName isEqualToString:@"objId"]){
            self.objID = paraValue;
        }else if ([paraName isEqualToString:@"emp_id"]){
            self.empID = paraValue;
        }else if ([paraName isEqualToString:@"id_extra"]){
            self.Id = paraValue;
        }else if ([paraName isEqualToString:@"sub_store_emp_id"]){
            self.sub_store_emp_id = paraValue;
        }else if ([paraName isEqualToString:@"key_orderno"]){
            self.orderNo = paraValue;
        }else if ([paraName isEqualToString:@"int_key_page_type"]){
            self.pagetype = paraValue;
        }else if ([paraName isEqualToString:@"nolnstallMsg"]){
            self.nolnstallMsg = paraValue;
        }else if ([paraName isEqualToString:@"displayName"]){
            self.displayName = paraValue;
        }else if ([paraName isEqualToString:@"extra_routeId"]){
            self.route_id = paraValue;
        }else if ([paraName isEqualToString:@"date_extra"]){
            self.date_extra = paraValue;
        }else if ([paraName isEqualToString:@"srid_extra"]){
            self.srid_extra = paraValue;
        }

    }
}

- (void)getViewControllerAndDataWithURL:(NSURL *)url completionBlock:(void (^)(WCBaseViewController *, NSError *))completionBlock
{
    [self processParameters:url];
    
    if ([url.host isEqualToString:@"store.acvtview"]) {
        //跳转acvt
        
        self.service = [[WSAcvtHttpService alloc] init];
        WSFuncsBean *funcsBean = [self getFuncsBean];
        
        NSString *empID = [WSAppData getObjectbyKey:EMPID];
        if (!self.empID) {
            self.empID = empID;
        }
        // 取代之前从内存中取值的操作，现在统一替换成从本地库里查
        WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
        WSAcvtBean *acvtBean = [service queryAcvtWithAcvtID:self.acvtID];
        WSStoreBean * storeBean = [self getStoreBean];
        
        NSString *leaveTime = [[WSInoutStoreTable sharedTable] getLeaveStoreTime:storeBean andOtherParam:nil andParamType:EParameterType_NULL];

        //SFA-13795 增加报表获取实时更新门店信息之后，根据是否离过店判定是否只读，若已经离店，不必进店就可以查看拜访项内容，但是内容都是只读的。
        if (leaveTime && ![leaveTime isEqualToString:@"null"] && ![funcsBean.required isEqualToString:@"E"]) {
            
            storeBean.inReadonlyMode = YES;
        }
        
        if (!funcsBean || !acvtBean) {
            NSDictionary *dic = @{@"msg": NSLocalizedString(@"refresh_failure", nil)};
            NSError *localError = [[NSError alloc] initWithDomain:@"errorDomain" code:0 userInfo:dic];
            
            completionBlock(nil, localError);
            
            return;
        }
        
        self.service.storeBean = storeBean;
        self.service.acvtBean = acvtBean;
        self.service.objID = self.objID;
        self.service.jsEmpID = self.empID;
        self.service.genID = self.genID;
        
        __weak typeof(self) wself = self;
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)  tips:nil tapTarget:self action:nil];
        
        [self.service getAcvtDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            
            if (error) {
                NSDictionary *dic = @{@"msg": NSLocalizedString(@"refresh_failure", nil)};
                NSError *localError = [[NSError alloc] initWithDomain:@"errorDomain" code:0 userInfo:dic];
                
                completionBlock(nil, localError);
                
                return;
            }
//             SFALHLH-2161  【IOS】调查问卷没有回显
                NSDictionary *dataInfo = dic;
                NSDictionary *storeDicInfo = nil;
                if ([dataInfo isKindOfClass:[NSDictionary class]]) {
                    storeDicInfo = (NSDictionary *)dataInfo;
                }else if ([dataInfo isKindOfClass:[NSArray class]]) {
                    storeDicInfo = [(NSArray *)dataInfo firstObject];
                }
                
                NSArray *allKeys = [storeDicInfo allKeys];
                // MN-760 新增调查问卷下，服务器实时返回acvtDis回显数据的genId
                NSString *realTimeAcvtDisGenId = nil;
                for (NSString *key in allKeys) {
                    if ([key hasPrefix:STOREACVTDIS] || [key hasPrefix:ACVTDIS]) {
                        NSArray *acvtDisDictsArray = [storeDicInfo objectForKey:key];
                        NSDictionary *firstDisDic = [acvtDisDictsArray firstObject];
                        realTimeAcvtDisGenId = [firstDisDic objectForKey:@"gen_id"];
                        break;
                    }
                }
               
            [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:storeDicInfo genId:nil isRemoteSearch:NO];

            // MMSH-2675 [玛氏中国MWC](ios)从业代-报表-跳问卷，上传时需要带上srId
            WSAcvtViewController *acvtController = [[WSAcvtViewController alloc] initWithAcvt:acvtBean Funcs:funcsBean Store:storeBean md5:wself.genID isFromRealTimeData:YES SubEmpId:wself.srid_extra];
            acvtController.objID = wself.objID;
//            董宏 YIHAIKERRY-4686
            if([[url absoluteString] rangeOfString:@"finishPage=1"].location !=NSNotFound)
            {
                acvtController.isBackAccrossParent = YES;
            }
            completionBlock(acvtController, nil);
            
            wself.service = nil;
            
        }];
 
    }else if ([url.host isEqualToString:@"msg.view"]){
        

        //HUAWEI-197  店奖ios的点击商城页面，点击【销售激励专享】页面，提示"加载中"，才进入到"information_details",需调整为点击【销售激励专享】，进入到"information_details"页会才"加载"或"更新信息"
        WSDetalViewController * detalCtrl = [[WSDetalViewController alloc]init];
        detalCtrl.msgIDFromWebView = self.Id;
        
        completionBlock(detalCtrl, nil);
        
    }else if ([url.host isEqualToString:@"function"]){
        
        
        // MENGNIU-490 SFA蒙牛-【IOS】经销商老板进入订单中心，点击司机，未显示相应的地图
        WSFuncsBean *funcsBean = [self getFuncsBean];

        NSString *className = [WSPlistHelper valueForKey:funcsBean.fv withPlistName:kControllerMappingFileName];
        WCBaseViewController *  con = [[NSClassFromString(className) alloc] initWithFuncs:funcsBean];
        
        if ([con isKindOfClass:[WSSubEmpMapViewController class]]) {
            WSSubEmpMapViewController  *controller = (WSSubEmpMapViewController *)con;
            WSSubempstoreBean * subEomStoreBean = [[WSSubempstoreBean alloc]init];
            subEomStoreBean.Id = self.sub_store_emp_id;
            controller.subempStore = subEomStoreBean;
            controller.queryDate = self.date_extra;
        }
        
        completionBlock(con, nil);

    }else if ([url.host isEqualToString:@"route.storeroute"]){
        //
        if ([WSMainLeftViewManager getInstance].mainLeftView) {
            WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
            WSFuncsBean * funcsBean =  [funcsBeanArray getFuncsBeanWithFC:self.funcsCode];
            WSFuncsBean * pfuncsBean =  [funcsBeanArray getParentFuncsBeanWithFk:funcsBean.fk];
            [[WSMainLeftViewManager getInstance].mainLeftView showFuncsBean:pfuncsBean];
            [WSMainLeftViewManager getInstance].funcFc = self.funcsCode;
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@@%@",self.route_id,[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:ROUTE_PLAN_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
            completionBlock(nil, nil);

        }
    }else if ([url.host isEqualToString:@"enter_store"]){
        [self dealWithEnter_storeWithCompletionBlock:completionBlock];
    }
    
}

-(void)dealWithEnter_storeWithCompletionBlock:(void (^)(WCBaseViewController *, NSError *))completionBlock{
    
    WSFuncsBean *funcsBean = [self getFuncsBean];
    WSStoreBean * storeBean = [self getStoreBean];
    if (!funcsBean || !storeBean) {
        NSDictionary *dic = @{@"msg": NSLocalizedString(@"refresh_failure", nil)};
        NSError *localError = [[NSError alloc] initWithDomain:@"errorDomain" code:0 userInfo:dic];
        
        completionBlock(nil, localError);
        
        return;
    }
    self.getStoreDataService = [[WSStoreHttpService alloc]init];
    self.getStoreDataService.storeBean = storeBean;
    self.getStoreDataService.objID = self.objID;
    self.getStoreDataService.jsEmpID = self.empID;
    __weak typeof(self) wself = self;
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)  tips:nil tapTarget:self action:nil];
    [self.getStoreDataService getOutplanStoreDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
        
        if (error) {
            NSDictionary *dic = @{@"msg": NSLocalizedString(@"refresh_failure", nil)};
            NSError *localError = [[NSError alloc] initWithDomain:@"errorDomain" code:0 userInfo:dic];
            
            completionBlock(nil, localError);
            
            return;
        }
        WSWorkFlowViewController * con = [[WSWorkFlowViewController alloc]initWithFuncs:funcsBean Store:storeBean];
        WSVisitStoreActionObject * action = [[WSVisitStoreActionObject alloc]init];
        con.title = storeBean.name;
        action.title = funcsBean.name;
        action.store_id = storeBean.Id;
        action.func_code = funcsBean.fc;
        action.module_fc = funcsBean.fc;
        action.emp_id = wself.empID;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//        [[WSVisitStoreActionTable sharedTable] insertCurrentAction:action];
        
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        con.currentVisitAction = action;
        con.moduleFC = action.module_fc;
        completionBlock(con, nil);
        wself.getStoreDataService = nil;
    }];
    
}
-(WSFuncsBean *)getFuncsBean{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    return  [funcsBeanArray getFuncsBeanFromAllFucsWithFC:self.funcsCode];
}

-(WSStoreBean *)getStoreBean{
    // 取代之前从内存中取值的操作，现在统一替换成从本地库里查
    //    donghong SFA-17852 按照安卓逻辑修改 查询门店 不需要empid 只有 storeid
    WSStoreBean *storeBean =   [[WSStoreBean alloc] initstoreWithBaseStoreObject:[[WSBaseStoreDBService shareInstance] queryStoreWithId:self.storeID] isPlan:YES];

    
    
    if (storeBean) {
        storeBean = [storeBean copy];
        storeBean.plan = NO;
    } else if (self.storeID){
        storeBean = [[WSStoreBean alloc] initStoreWithId:self.storeID andName:nil andPlan:NO];
        storeBean.isFakeStore = YES;
    }
    return storeBean;
}
- (void)getJumpAPPAndDataWithURL:(NSURL *)url completionBlock:(void (^)(NSString* selectJump, NSError *error))completionBlock
{

        [self processParameters:url];
            //跳转外部app
        NSURL *urlJump = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/?orderNo=%@&pagetype=%@",self.displayName,url.host,self.orderNo,self.pagetype]];
        
        if ([[UIApplication sharedApplication] canOpenURL:urlJump]) {
            
            [[UIApplication sharedApplication] openURL:urlJump];
            
            completionBlock(@"",nil);
            
        }else{
            NSString *msg = self.nolnstallMsg ? self.nolnstallMsg : @"跳转外部应用失败";//稍后修改这里 董宏
            completionBlock(msg,nil);
        }
        
}

@end
