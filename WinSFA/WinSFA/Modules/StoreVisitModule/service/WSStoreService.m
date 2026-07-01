//
//  WSStoreService.m
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStoreService.h"
#import "WSStoreAcvtDisArray.h"
#import "WSStoreAcvtDisBean.h"
#import "WSInterAction.h"
#import "WSInoutStoreTable.h"
#import "WSRequestHelper.h"
#import "WSStoreBean.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSStoreInfoBeanArray.h"
#import "WSWorkFlowViewController.h"
#import "WSSqliteUtil.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSBaseAcvtDBService.h"

#define INPLAN_UPDATA_NOTIFY @"INPLAN_UPDATA_NOTIFY"

#define UPDATE_STORE_NOTIFY       @"update_store_notify"

@interface WSStoreService (private)

//根据过滤项目来查询acvt
-(WSAcvtBean *)queryAcvtInfoByFilter:(NSString *)filter;
//根据acvtId和searchTag查询相关的店铺id数组
-(NSMutableArray *)queryRelationStoreIdFromTheStoreAcvtDisBy:(NSString *)acvtId andSearchTag:(NSString *)searchTag;

//根据storeIds查询StoreInfo数组
-(NSMutableArray *)queryStoreInfoByStoreIds:(NSMutableArray *)storeIds;


-(NSMutableArray *) getStoreInfoByIds:(NSMutableArray *)storeIds andStores:(NSMutableArray *)stores;

@property (nonatomic, assign) BOOL isInitOtherFuncBeans;

@end

@implementation WSStoreService

-(id)init{
    
    self = [super init];
    if (self) {
        
        
        return self;
    }
    
    return nil;
}


-(void)initOtherFuncsBean
{
    // 目前情况是funcsBeanDic 里最多有两种funcsBean.如果超过两种再订方案 主要是 sortStoreListArrayByVisitAction 方法排序使用。
    if (!self.funcsBeanDic) {
        
        self.funcsBeanDic = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    switch (self.todayVisitCategory) {
            
        case WSTodayVisitCategoryInPlan: //只有计划内
        {
            if (currentFuncs) {
                
                [self.funcsBeanDic setObject:currentFuncs forKey:@"TAB_V2001"];
            }
        }
            break;
        default:
        {
            
            if (!self.isInitOtherFuncBeans) {
                
                self.isInitOtherFuncBeans = YES;
                
                WSFuncsBean *superBarFuncsBean = nil;
                
                NSString *stringFC = nil;
                
//                if(self.ownParentViewController && [self.ownParentViewController isKindOfClass:[WSCustomerVistViewController class]]){
//                
//                    WSCustomerVistViewController *controller = (WSCustomerVistViewController *)self.ownParentViewController;
//                
//                    stringFC = controller.currentFuncs.fc;
//                
//                }
                
                // FCbean : 计划内    ，计划外，    新门店，             动态搜索计划外
                // key    : TAB_V2001  TAB_V2002  TAB_V2002_newstore TAB_V11001(TAB_V21002)
                if (currentFuncs) {
                    [self.funcsBeanDic setObject:currentFuncs forKey:@"TAB_V2001"];
                }
                
                WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
                for (WSFuncsBean *funcs in fba.funcsArray) {
                    if ([funcs.fv isEqualToString:@"TB_V20"] && [funcs.fc isEqualToString:stringFC]) {
                        superBarFuncsBean = funcs;
                        break;
                    }
                }
                
                if (superBarFuncsBean) {
                    
                    for (WSFuncsBean* fb in superBarFuncsBean.funcsArray) {
                        
                        if ([fb.fv isEqualToString:@"TAB_V2002"] && (!fb.ds || [fb.ds length] < 1)) { //资源是固定的，所以硬编码 TAB_V2002【门店清单】。
                            self.outPlanFuncsBean = fb;
                            if (self.outPlanFuncsBean) {
                                [self.funcsBeanDic setObject:self.outPlanFuncsBean forKey:@"TAB_V2002"];
                            }
                        }else if ([fb.fv isEqualToString:@"TAB_V2002"] && (fb.ds && [fb.ds isEqualToString:@"newstore"])) { //资源是固定的，所以硬编码 TAB_V2002 + newstore(ds)【新门店】。
                            self.newstoreFuncsBean = fb;
                            if (self.newstoreFuncsBean) {
                                [self.funcsBeanDic setObject:self.newstoreFuncsBean forKey:@"TAB_V2002_newstore"];
                            }
                        }else if ([fb.fv isEqualToString:@"TAB_V11001"]) { //资源是固定的，所以硬编码 TAB_V11001【计划外搜索】。 与 TAB_V21002 用的是同一个页面。暂作兼容
                            self.outPlanSearchFuncsBean = fb;
                            if (self.outPlanSearchFuncsBean) {
                                [self.funcsBeanDic setObject:self.outPlanSearchFuncsBean forKey:@"TAB_V11001"];
                            }
                        }else if ([fb.fv isEqualToString:@"TAB_V21002"]){
                            self.outPlanSearchFuncsBean2 = fb;
                            if (self.outPlanSearchFuncsBean2) {
                                [self.funcsBeanDic setObject:self.outPlanSearchFuncsBean2 forKey:@"TAB_V21002"];
                            }
                            
                        }
                    }
                }
            }
        }
            break;
    }
    
    
}


-(void)queryStoreListByFunc:(WSInterAction *)interaction{
    
    
    current_interaction = interaction;
    
    currentFuncs = (WSFuncsBean *)[interaction  inner_param];
    
    
    
    NSString *filter = currentFuncs.filter;
    
    NSString *search_tag = currentFuncs.opt.searchTag;
    
    WSAcvtBean *acvt = [self queryAcvtInfoByFilter:filter];
    
    NSMutableArray *StoreIdarray =[self queryRelationStoreIdFromTheStoreAcvtDisBy:[acvt acvtId] andSearchTag:search_tag];
    
    NSMutableArray *storeInfos = [self queryStoreInfoByStoreIds:StoreIdarray];
    
    [interaction setExecute_result:storeInfos];
    
    if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteSuccessed:andResultObject:)]) {
        
        [self.service_call_back_delegate serviceExecuteSuccessed:self andResultObject:interaction];
        
    }
}

-(WSAcvtBean *)queryAcvtInfoByFilter:(NSString *)filter{
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:nil filter:filter];
    
    return [filtersArray firstObject];
}

-(NSMutableArray *)queryRelationStoreIdFromTheStoreAcvtDisBy:(NSString *)acvtId andSearchTag:(NSString *)searchTag{
    
    NSMutableArray *array =[[NSMutableArray alloc] init];
    
    WSStoreAcvtDisArray  *storeacvtdisarray = [[self.appdata datas] valueForKey:STOREACVTDIS_STORE];
    @try {
        for (int i=0; i<[[storeacvtdisarray storeAcvtDisArray] count]; i++) {
            
            
            WSStoreAcvtDisBean *storeAcvtDis =[[storeacvtdisarray storeAcvtDisArray] objectAtIndex:i];
            
            NSArray  *storedisplaypolicy = [storeAcvtDis m_p];
            
            NSString *storeId = [storedisplaypolicy objectAtIndex:0];
            
            NSString  *acvtId =[storedisplaypolicy objectAtIndex:1];
            
//            NSString  *acvt_qst_Id = [storedisplaypolicy objectAtIndex:2];
            
            NSString  *acvtMatchAnswer = [storedisplaypolicy objectAtIndex:3];
            
            if ([acvtId isEqualToString:acvtId] && [acvtMatchAnswer isEqualToString:searchTag]) {
                
                [array addObject:storeId];
            }
            
        }
    }
    @catch (NSException *exception) {
        
        LogError(@"===>>>>> %@",exception);
    }
    @finally {
        
    }

    
    return array ;
    
}

-(NSMutableArray *)queryStoreInfoByStoreIds:(NSMutableArray *)storeIds{

    NSMutableArray *inplanstoreArray = [(WSInPlanStoreBean *)[WSAppData getObjectbyKey:INPLANSTORE] storesArray];
    
    NSMutableArray *outplanstoreArray = [(WSOutPlanStoreBean *)[WSAppData getObjectbyKey:OUTPLANSTORE] storesArray];
    
    NSMutableArray *filteredinstorearray = [self getStoreInfoByIds:storeIds andStores:inplanstoreArray];
    
    NSMutableArray *filteredoutstorearray = [self getStoreInfoByIds:storeIds andStores:outplanstoreArray];
   
    NSArray  *inplanss = [self getAndUpdateStoreVisitStatusInMemory:filteredinstorearray];
    
    NSArray  *outplanss = [self getAndUpdateStoreVisitStatusInMemory:filteredoutstorearray];
    
    NSMutableArray  *filterResultArray = [[NSMutableArray alloc] init];
    
    [filterResultArray addObjectsFromArray:inplanss];
    
    [filterResultArray addObjectsFromArray:outplanss];
    
    
    
    return [self reSortStoreListByAccessType:filterResultArray];
    
}


-(NSMutableArray *)reSortStoreListByAccessType:(NSMutableArray *)filteredArray{
    
    
    NSMutableArray *filteredResult =[[NSMutableArray alloc] init];
    
    NSMutableArray *accessedResult =[[NSMutableArray alloc] init];
    
    for (int i=0; i<[filteredArray count]; i++) {
        
        WSStoreBean *storeBean = [filteredArray objectAtIndex:i];
        if (storeBean.access_status!=ACCESS_STATUS_TYPE_OUT) {
            [filteredResult addObject:storeBean];
        }else{
            
            [accessedResult addObject:storeBean];
        }
    }
    [filteredResult addObjectsFromArray:(NSArray *)accessedResult];
    return filteredResult;
    
}

-(NSArray *)getAndUpdateStoreVisitStatusInMemory:(NSMutableArray *)array{
    
    NSMutableArray  *storeArray= [[NSMutableArray alloc] init];
    
    for (int i=0; i<[array count]; i++) {
        
        WSStoreBean *storebean =[array objectAtIndex:i];
        
        [storebean setAccess_status:0];
        
        WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:currentFuncs];
        
        NSString *func=subMenuFB.fc;
        
        if (subMenuFB == nil) {
            
            
            func= currentFuncs.fc;
            
        }
        
        if ([[WSInoutStoreTable sharedTable] isEnterStore:storebean andOtherParam:func andParamType:EParameterType_ParentFC]) {
            
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:storebean andOtherParam:func andParamType:EParameterType_ParentFC]){
                
                [storebean setAccess_status:1];
                
            }else{
                
                [storebean setAccess_status:2];
                
            }
    
        }
        
        [storeArray addObject:storebean];
    }
    
    return (NSArray *)storeArray;
}




-(NSMutableArray *) getStoreInfoByIds:(NSMutableArray *)storeIds andStores:(NSMutableArray *)stores{
   
    NSMutableArray *arrays = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[storeIds count]; i++) {
        
        NSString  *storeId = [storeIds objectAtIndex:i];
        
        for (WSStoreBean  *store in stores) {
            if ([storeId isEqualToString: [store sid]]) {
                [arrays addObject:store];
            }
        }
    }
    
    return arrays;
}

//待实现函数

-(NSMutableArray *)queryStoreInfoByStoreKey:(NSString *)store andStoreIds:(NSMutableArray *)storeIds{
    
    return [[[WSAppData sharedManager] datas] valueForKey:store];
    
    NSMutableArray  *storeArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[storeIds count]; i++) {
        
    }
    
    return storeArray;
    
}


-(void)generateJumpInfo:(WSInterAction *)interaction{

    current_interaction = interaction;
    
    WSStoreBean *store = (WSStoreBean *)interaction.inner_param;
    
    currentStore = store;
    
    currentFuncs = (WSFuncsBean *)[interaction getEnvValueForKey:@"currentFuncs"];

    currentVisitAction = (WSVisitStoreActionObject *)[interaction getEnvValueForKey:@"currentVisitAction"];
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:currentFuncs];
    
    
    NSString *moduleFC = nil;
    if (currentVisitAction
        && currentVisitAction.module_fc
        && [currentVisitAction.module_fc length] > 0) {
        moduleFC = currentVisitAction.module_fc;
    }else if(subMenuFB && [subMenuFB.fc length] > 0){
        moduleFC = subMenuFB.fc;
    }else {
        moduleFC = currentFuncs.fc;
        
    }
    
    if ([self anyStoreHasNotLeave:currentStore andModuleFC:moduleFC]) {
        
        [self processStore:store withFuncsBean:currentFuncs];
    }
    
}

- (void)processStore:(WSStoreBean *)store withFuncsBean:(WSFuncsBean *)funcsBean {
    
    if (store.plan && ![funcsBean.opt.isIntentToStore isEqualToString:@"Y"]) {
        
        [self goNextWorkView];
        
    }else{
        
        [self processForOutplan:store];
    }
}

-(void)processForOutplan:(WSStoreBean *)store{
    
    if([currentFuncs.ds isEqualToString:@"hos"]){
        [self startUpdateHosData:store];
        
    }else {
        [self startUpdataManager:store];
    }
}

-(void)startUpdataManager:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATE_STORE_NOTIFY
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    if (currentStore.styp  && [currentStore.styp length] > 0) {
        
        NSString *styp = [currentStore.styp copy];
        [uploadMgr appUpdataManagerInfo:store subempId:nil withObjId:[self getObjID] notifyName:UPDATE_STORE_NOTIFY styp:styp];
    }else {
        [uploadMgr appUpdataManagerInfo:store subempId:nil  withObjId:[self getObjID] notifyName:UPDATE_STORE_NOTIFY styp:nil];
    }
    
    
    NSString *AccessInforString = NSLocalizedString(@"querying_message",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];

}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATE_STORE_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    NSDictionary *uploadState = [info objectFromJSONString];
    
    NSDictionary* vflag=[[uploadState objectForKey: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME] firstObject];
    if([vflag objectForKey:@"vflag"]){
        NSNumber* vflagNumber=[vflag objectForKey:@"vflag"];
        if(vflagNumber.integerValue==0){
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"代表未进店" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
    }
    
    NSString *objIdStr = [self getObjID];
    
    if (currentStore != nil) {
    
        [currentStore reSetStore:uploadState Key:objIdStr];
    
    }
    
    [self dealWithStoreDictdis:uploadState withNodeName:objIdStr];
    
    [self dealWithStoreInfo:uploadState withNodeName:objIdStr withFilter:currentFuncs.filter];
    
    [self addUpdateStoreInfoToAppdata:uploadState noteName:objIdStr];
    
    [self goNextWorkView];
    
}

-(void)startUpdateHosData:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequestForHos:)
                                                 name:@"PFIZERGETDOCTOR"
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr fetchHospitalInfo:store notifyName:@"PFIZERGETDOCTOR"];
    
    NSString *AccessInforString = NSLocalizedString(@"querying_message",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];
}

- (void)finishRequestForHos:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PFIZERGETDOCTOR" object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *uploadState = [info objectFromJSONString];
    if (currentStore) {
        [currentStore reSetStore:uploadState Key:@"spestoreinfo"];
    }
    [self dealWithStoreDictdis:uploadState withNodeName:@"spestoreinfo"];
    [self dealWithStoreInfo:uploadState withNodeName:@"spestoreinfo" withFilter:currentFuncs.filter];
    
    [self addUpdateStoreInfoToAppdata:uploadState noteName:@"spestoreinfo"];
    
    [self goNextWorkView];
}


- (void)dealWithStoreDictdis:(NSDictionary *)uploadState withNodeName:(NSString *)aNodeName
{
    NSArray *arr = [uploadState objectForKey:aNodeName];
    NSDictionary *dic = [arr objectAtIndex:0];
    
    NSArray *acvtdisArray = [dic objectForKey:STOREACVTDIS];
    for (NSDictionary *item in acvtdisArray)
    {
        WSStoreAcvtDisBean *sb = [[WSStoreAcvtDisBean alloc]initWithObject:item];
        [currentStore.acvtDisArray addObject:sb];
    }
    
    WSStoredDictDisArray *storeDictDisArray = [WSAppData getObjectbyKey:STOREDICTDIS];
    if (storeDictDisArray == nil
        || storeDictDisArray.storedDictDisArray == nil
        || [storeDictDisArray.storedDictDisArray count] < 1 )
    {
        storeDictDisArray = [[WSStoredDictDisArray alloc] initWithObject:dic];
        [WSAppData putObject:storeDictDisArray forKey:STOREDICTDIS];
        
    }
    else
    {
        NSArray *sdaArray= [storeDictDisArray.storedDictDisArray copy];
        
        for (WSStoredDictDisBean *item in sdaArray)
        {
            if ([[item.m_p firstObject] isEqualToString:currentStore.Id])
            {
                [storeDictDisArray.storedDictDisArray removeObject:item];
            }
        }
        WSStoredDictDisArray *newStoreDictDisArray = [[WSStoredDictDisArray alloc] initWithObject:dic];
        [storeDictDisArray.storedDictDisArray addObjectsFromArray:newStoreDictDisArray.storedDictDisArray];
    }
    
}

- (void)addUpdateStoreInfoToAppdata:(NSDictionary *)aDic noteName:(NSString *)aNoteName {
    NSArray *array = [aDic objectForKey:aNoteName];
    NSDictionary *dicInfo = [array objectAtIndex:0];
    if (dicInfo != nil) {
        [[WSAppData sharedManager].datas setObject:dicInfo forKey:aNoteName];
    }
}



/**
 *  通过服务端获取当前门店详情时，self.currentStore 非空。
 *  通过服务端搜索匹配关键字的门店列表时，self.currentStore 为空。
 *
 *  @return <#return value description#>
 */
- (NSString *)getObjID
{
    NSString *objId = nil;
    WSFuncsBean *subFunc = nil;
    if (currentFuncs.funcsArray != nil && [currentFuncs.funcsArray count] > 0) {
        subFunc = [currentFuncs.funcsArray objectAtIndex:0];
    }
    
    if (currentStore) {
        
        if (subFunc != nil && subFunc.filter != nil && [subFunc.filter length] > 0) {
            objId = subFunc.filter;
        }else if([currentFuncs.fv isEqualToString:@"TAB_V11001"]
                 ||  (subFunc && [subFunc.fv isEqualToString:FV_TAB_V21001])){ //
            objId =  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
        } else {
            objId = @"allplanstoreontime";
        }
        
    }else{
        
        if (subFunc != nil && subFunc.filter != nil && [subFunc.filter length] > 0) {
            objId = subFunc.filter;
        }else if([currentFuncs.fv isEqualToString:FV_TAB_V21001]){ // 此处修改为和安卓保持一致
            objId =  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
        } else if([currentFuncs.fv isEqualToString:@"TAB_V13001"]){
            objId = @"subempoutstore";
        }else {
            objId = @"allplanstoreontime";
        }
        
    }
    return objId;
}

- (void)dealWithStoreInfo:(NSDictionary *)uploadState withNodeName:(NSString *)aNodeName withFilter:(NSString *)filterString
{
    NSArray *newDatasArray = [uploadState objectForKey:aNodeName];
    NSDictionary *newDatas = [newDatasArray firstObject];
    
    //新本地数据集合
    NSMutableArray* newStoreInfoArray= [[NSMutableArray alloc] init];
    
    //本地数据集合
    WSStoreInfoBeanArray *loginStoreInfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
    
    //获取服务器返回的更新信息。
    WSStoreInfoBeanArray *storeinfoBeans = [[WSStoreInfoBeanArray alloc] initWithObject:newDatas];
    
    
    while ([storeinfoBeans.storeinfoArray count] > 0) {
        
        @autoreleasepool {
            
            WSStoreInfoBean* storeInfo_temp = [storeinfoBeans.storeinfoArray firstObject];
            
            if ((storeInfo_temp.empId && [storeInfo_temp.empId length] > 0)
                && (!storeInfo_temp.storeId || [storeInfo_temp.storeId length] < 1 )) { //处理对账号业务
                
                NSMutableArray *removeArray = [NSMutableArray arrayWithCapacity:2];
                
                for (WSStoreInfoBean *temp in loginStoreInfoBeans.storeinfoArray) {
                    if (temp.empId
                        && [temp.empId length] > 0
                        && [temp.empId isEqualToString:storeInfo_temp.empId]) {
                        
                        //如果此业务不提供过滤器字段则，只能获取新信息的类型来处理，尽量缩小匹配范围。
                        NSString * stringFilter = filterString;
                        if (!stringFilter || [stringFilter length] < 1) {
                            
                            stringFilter = storeInfo_temp.typ;
                        }
                        
                        if (stringFilter
                            && [stringFilter length] > 0
                            && [stringFilter isEqualToString:temp.typ]) { //新信息的有类型的，并且能在客户端找到同样类型的旧信息
                            
                            [removeArray addObject:temp];
                        }else if (!stringFilter && !temp.typ){            //新信息是无类型，并且在客户端也存在无类型的旧信息
                            
                            [removeArray addObject:temp];
                        }
                    }
                }
                if ([removeArray count] > 0) {
                    [loginStoreInfoBeans.storeinfoArray removeObjectsInArray:removeArray];
                }
                [newStoreInfoArray addObject:storeInfo_temp];
                
            }else if ((storeInfo_temp.storeId && [storeInfo_temp.storeId length] > 0)
                      && (!storeInfo_temp.empId || [storeInfo_temp.empId length] < 1 )){ //处理对店业务 暂时不需要处理
                
                //                目前对店业务只有PI类型表格支持，PI表格的数据在登录时更新。不需要临时请求。
                //                NSMutableArray *removeArray = [NSMutableArray arrayWithCapacity:2];
                //
                //                for (WSStoreInfoBean *temp in loginStoreInfoBeans.storeinfoArray) {
                //                    if (temp.storeId
                //                        && [temp.storeId length] > 0
                //                        && [temp.storeId isEqualToString:storeInfo_temp.storeId]) {
                //
                //                        NSString * stringFilter = filterString;
                //                        if (!stringFilter || [stringFilter length] < 1) {
                //
                //                            stringFilter = storeInfo_temp.typ;
                //                        }
                //
                //                        if (stringFilter
                //                            && [stringFilter length] > 0
                //                            && [stringFilter isEqualToString:temp.typ]) { //新信息的有类型的，并且能在客户端找到同样类型的旧信息
                //
                //                            [removeArray addObject:temp];
                //                        }else if (!stringFilter && !temp.typ){            //新信息是无类型，并且在客户端也存在无类型的旧信息
                //
                //                            [removeArray addObject:temp];
                //                        }
                //                    }
                //                }
                //
                //                if ([removeArray count] > 0) {
                //                    [loginStoreInfoBeans.storeinfoArray removeObjectsInArray:removeArray];
                //                }
                //                [newStoreInfoArray addObject:storeInfo_temp];
            }else if ((storeInfo_temp.storeId && [storeInfo_temp.storeId length] > 0)
                      && (storeInfo_temp.empId && [storeInfo_temp.empId length] > 0 )) {
                NSMutableArray* removeArray=[NSMutableArray array];
                [loginStoreInfoBeans.storeinfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSStoreInfoBean *loginStoreInfo = (WSStoreInfoBean *)obj;
                    if (loginStoreInfo.storeId
                        &&storeInfo_temp.storeId
                        && loginStoreInfo.typ
                        && storeInfo_temp.typ
                        && [loginStoreInfo.storeId isEqualToString:storeInfo_temp.storeId]
                        && [loginStoreInfo.typ isEqualToString:storeInfo_temp.typ]) {
                        [removeArray addObject:loginStoreInfo];
                    }
                    
                }];
                
                [loginStoreInfoBeans.storeinfoArray removeObjectsInArray:removeArray];
                [newStoreInfoArray addObject:storeInfo_temp];
                
            }else{
                
                LogError(@"返回店信息有错误！为了不丢失数据，只能追加=%@" ,storeInfo_temp);
                [newStoreInfoArray addObject:storeInfo_temp];
            }
            
            [storeinfoBeans.storeinfoArray removeObject:storeInfo_temp];
            
        }
        
    }
    
    //追加需要更新的数据。
    [loginStoreInfoBeans.storeinfoArray addObjectsFromArray:newStoreInfoArray];
    [WSAppData putObject:loginStoreInfoBeans forKey:STOREINFOS];
}

- (WSVisitStoreActionObject*) findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
                                        andCurrentVisitAction:(WSVisitStoreActionObject *)currentAction
                                                   andStoreId:(NSString *)store_id
{
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = currentAction.ID;
    action.store_id = store_id;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = funcsBean.name;
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:currentFuncs];
    
    if (subMenuFB == nil) {
        
        action.module_fc = action.func_code;
    }
    
    
    
    return action;
}



#pragma mark -  old code
-(void)goNextWorkView
{
    //以下code因submenu而改
    if ([currentFuncs.funcsArray count]<1) {
        return;
    }
    
    WSWorkFlowViewController* wfvc = nil;
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:currentFuncs];
    
        
    wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:subMenuFB Store:currentStore];
    wfvc.input_reflect_code = subMenuFB.fc ;
  
   
    
    // Add UIViewController
    if ([currentStore.name isKindOfClass:[NSString class]] && ![currentStore.name isEqualToString:@""]) {
        wfvc.title = currentStore.name;
    }
    
    //设置访问节点
    
    wfvc.currentVisitAction = [self findActionIDAndCreateNextAction:currentFuncs andCurrentVisitAction:currentVisitAction andStoreId:currentStore.Id];
    
    wfvc.moduleFC = wfvc.currentVisitAction.func_code;
    
    [current_interaction setExecute_result:wfvc];
    
    if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteSuccessed:andResultObject:)]) {
        
        [self.service_call_back_delegate serviceExecuteSuccessed:self andResultObject:current_interaction];
    }
}


//根据当前store和fc编码来确定是否有未离店的情况
-(BOOL)anyStoreHasNotLeave:(WSStoreBean*)aStore andModuleFC:(NSString *)store_moduleFC
{
    WSInoutStoreObject *inoutStoreObject = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    
    if(inoutStoreObject &&
       ![currentFuncs.required isEqualToString:@"E"] &&
       (![inoutStoreObject.store_id isEqualToString:aStore.Id] || ([inoutStoreObject.store_id isEqualToString:aStore.Id] && ![inoutStoreObject.modulefc isEqualToString:store_moduleFC])))
    {
        NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",inoutStoreObject.memo1,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_STORE_NOTIFY object:nil];
}

@end
