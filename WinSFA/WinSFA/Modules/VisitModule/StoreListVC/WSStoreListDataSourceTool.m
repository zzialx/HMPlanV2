//
//  WSStoreListDataSourceTool.m
//  WinSFA
//
//  Created by sunhf on 2018/1/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSStoreListDataSourceTool.h"
typedef void (^RequestBlock) (id);
#define INPLAN_UPDATA_NOTIFY @"INPLAN_UPDATA_NOTIFY"
#define UPDATA_NOTIFY        @"outPlan_notify"

static RequestBlock successBlock;
static RequestBlock failCallback;
static NSInteger allInPlanStoreCount;
@implementation WSStoreListDataSourceTool
#pragma mark - 获得今日拜访列表数据
+ (NSMutableArray *)initStoreListDataSourceWithFuncBean:(WSFuncsBean *)currentFuncs withSubempstoreBean:(WSSubempstoreBean *)subempStore
{
    //所有查询出来的门店数据数组
    NSMutableArray *storeDataArray = [NSMutableArray array];
    
    // 获得计划内门店个数
    [storeDataArray addObjectsFromArray:[[self class] initDataArrayFromDbWithFuncBean:currentFuncs withSubempstoreBean:subempStore]];
    
    //计划外已拜访的门店
    for (WSFuncsBean *fucsBean in currentFuncs.iParentFuncsBean.funcsArray) {
        
        if (![fucsBean.fc isEqualToString:currentFuncs.fc])
        {
            //获得计划外已拜访的门店
           [storeDataArray addObjectsFromArray:[[self class] addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:fucsBean withSubempstoreBean:subempStore]];
        }
    }
    
    // 查出来的门店去重    SFA 项目 SFA-7955
    [[self class] duplicateRemoval:storeDataArray];
    
    /**
     *  计划内门店和计划外已经拜访的要按照拜访计划的顺序排序 正在拜访的排最前面 已经拜访完成离店的放在最后 未开始拜访的放 正在拜访和已经结束拜访之间
     */
    [[self class] sortStoreFromDBWithDataArray:storeDataArray];

    return storeDataArray;
}

#pragma mark - 计划内门店
/*
 获得计划内门店个数  计划内门店又有两种数据来源  一种是有计划路线功能用户自己添加的 一种是没有计划路线功能后台推送的 需要分别获得数据 然后统一放到数组中
 1.searchobjId 下属的拼接
 2.sty 拼接
 */
+ (NSMutableArray *)initDataArrayFromDbWithFuncBean:(WSFuncsBean *)currentFuncs  withSubempstoreBean:(WSSubempstoreBean *)subempStore
{
    NSString * search_objId = STORES;
    if ([currentFuncs.ds length] > 0)
    {
        search_objId = currentFuncs.ds;
    }
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (subempStore != nil && subempStore.Id.length > 0)
    {
        empId = subempStore.Id;
    }
    NSMutableArray *inPlanStoreDataArray = [NSMutableArray array];
    //没有计划线路功能的app,但是后台给推送拜访计划的门店  标准产品的逻辑
    [inPlanStoreDataArray  addObjectsFromArray:[[self class] queryStoresFromDbWithFuncs:currentFuncs searchObjId:search_objId empId:empId subempstoreBean:subempStore]];
    
    // 有计划路线功能的app的门店  辉瑞医院专有
   [inPlanStoreDataArray addObjectsFromArray:[[self class] queryRoutePlanStoreWithFuncBean:currentFuncs withSubempstoreBean:subempStore]];
    //记录计划内没电个数
    allInPlanStoreCount = inPlanStoreDataArray.count;
    return inPlanStoreDataArray;
}

/*
 获得有计划路线功能的app的计划内门店  SFA-13481   辉瑞医院专有
 */
+ (NSMutableArray *)queryRoutePlanStoreWithFuncBean:(WSFuncsBean *)currentFuncs  withSubempstoreBean:(WSSubempstoreBean *)subempStore
{
    NSMutableArray * routeArray = (NSMutableArray *)[[[NSUserDefaults standardUserDefaults] objectForKey:ROUTE_PLAN_ID] componentsSeparatedByString:@"@"];
    NSString * bizeDate = [routeArray lastObject];
    NSString * routePlanId;
    if ([bizeDate isEqualToString:[WSAppData getObjectbyKey:APPDATA_BIZDATE]])
    {
        routePlanId = [routeArray firstObject];
    }
    
    if (!routePlanId)
    {
        [routeArray removeAllObjects];
     return routeArray;
    }
    NSString * search_objId = STORES;
    if ([currentFuncs.ds length] > 0)
    {
        search_objId = currentFuncs.ds;
    }
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (subempStore != nil && subempStore.Id.length > 0)
    {
        empId = subempStore.Id;
    }
    NSArray * routePlanArray = [[WSBaseStoreDBService  shareInstance] queryRoutePlanStoresByFuncCode:currentFuncs.fc SearchObjId:search_objId empId:empId route_id:routePlanId];
    
    NSMutableArray *storesCopy = [NSMutableArray array];
    for (WSStoreBean *storeBean in  routePlanArray) {
        WSStoreBean *object = [storeBean copy];
        object.mappingStoreFc = currentFuncs.fc;
        [storesCopy addObject:object];
    }
    return storesCopy;
}

/*
没有计划线路功能的app,但是后台给推送拜访计划的门店  标准产品的逻辑
 */
+ (NSMutableArray *)queryStoresFromDbWithFuncs:(WSFuncsBean *)currentFuncs searchObjId:(NSString *)search_objId empId:(NSString *)empId subempstoreBean:(WSSubempstoreBean *)subempStore
{
    NSString *styp = currentFuncs.styp;
    if ([currentFuncs.filter length] >  0)
    {
        search_objId = currentFuncs.filter;
    }
    else if ([currentFuncs.ds length] > 0)
    {
        search_objId = currentFuncs.ds;
    }
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    return [[WSBaseStoreDBService  shareInstance] queryInPlanStoresWithFuncCode:currentFuncs.fc empId:empId  search_objId:search_objId styp:styp biz_date:biz_date storeAccessMode:[subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal otherDataDic:nil];
}

#pragma mark - 计划外门店
/*
 获取计划外搜索出来的门店 && 计划外随访实时搜索出来的门店
 */
+ (NSMutableArray *)addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:(WSFuncsBean *)funcsBean withSubempstoreBean:(WSSubempstoreBean *)subempStore
{
    NSString *empId = subempStore ? subempStore.Id :[WSAppData getObjectbyKey:APPDATA_EMPID] ;
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:funcsBean];
    NSString *modelFc = subMenuFB.fc.length > 0 ? subMenuFB.fc : funcsBean.fc;
    WSBaseStoreDBService *baseStoreDBSevice = [[WSBaseStoreDBService alloc] init];
    NSArray *visitedStores = [baseStoreDBSevice queryOutPlanVisitingAndVisvitedStoresWithFuncCode:modelFc empId:empId];
    
    NSMutableArray *storesCopy = [NSMutableArray array];
    for (WSStoreBean *storeBean in  visitedStores) {
        WSStoreBean *object = [storeBean copy];
        object.mappingStoreFc = funcsBean.fc;
        [storesCopy addObject:object];
    }
    return storesCopy;
}

#pragma mark - 对门店按照规则要求排序
/*
 拜访中在最上面 已完成拜访在最下 没拜访过的放两者之间
 */
+ (NSMutableArray *)sortStoreFromDBWithDataArray:(NSMutableArray *)storeDataArray;
{
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *notStartArray = [NSMutableArray array];
    NSMutableArray *completerArray = [NSMutableArray array];
    
    for (WSStoreBean *storeBean in storeDataArray) {
        if ([storeBean.actionState isEqualToString:ActionWorking])
        {
            [array addObject:storeBean];
        }
        else if ([storeBean.actionState isEqualToString:ActionDone])
        {
            [completerArray addObject:storeBean];
        }
        else
        {
            [notStartArray addObject:storeBean];
        }
    }
    
    [array addObjectsFromArray:notStartArray];
    [array addObjectsFromArray:completerArray];
    [storeDataArray removeAllObjects];
    [storeDataArray addObjectsFromArray:array];
    return storeDataArray;
}

#pragma mark - 对门店按照规则要求排序 - 辉瑞医院 SFA-16255
/*
 排序方式：从上到下
 从A级别医院到D级别医院
 从当月拜访次数为0的医院到当月拜访次数多次
 */
+ (NSMutableArray *)sortStoreWithDataArray:(NSMutableArray *)storeDataArray
{
    //放置分组条件的数组
    NSMutableArray *item_nameArray = [NSMutableArray array];
    //放置所有子分组的整体数组
    NSMutableArray *allSubLevelArray = [NSMutableArray array];
    //没有分类的单独拿出来放的数组
    NSMutableArray *noItem_nameArray= [NSMutableArray array];
    
    for (WSStoreBean *storeBean in storeDataArray) {
        //根据item_name 进行分组 并且创建装对应分组数据的数组
        if (![item_nameArray containsObject:storeBean.item_name] && storeBean.item_name)
        {
            [item_nameArray addObject:storeBean.item_name];
            NSMutableArray *subLevelArray = [NSMutableArray array];
            [allSubLevelArray addObject:subLevelArray];
        }
        
        if (!storeBean.item_name && ![noItem_nameArray containsObject:storeBean])
        {
            [noItem_nameArray addObject:storeBean];
        }
    }
    
    //将分组名字 按照 字母A B  C D  等排序  并将属于改组数据放到对应的子数组中
    NSArray *sortItem_nameArray = [item_nameArray sortedArrayUsingSelector:@selector(compare:)];
    
    for (int i = 0; i < sortItem_nameArray.count; i++) {
        
        NSString *item_name = sortItem_nameArray[i];
        NSMutableArray *subLevelArray = allSubLevelArray[i];
        
        for (WSStoreBean *storeBean in storeDataArray)
        {
            if ([storeBean.item_name isEqualToString:item_name])
            {
                [subLevelArray addObject:storeBean];
            }
        }
    }
    
    //删除旧数据
    [storeDataArray removeAllObjects];
    //将排序后的数据从新加入到数组中
    for (NSMutableArray *subLevelArray in allSubLevelArray)
    {
        /*将每个子数组中的storeBean  根据您store_month_visit_time 当月拜访次数 由低到高排序  没有值得放最前面*/
        //取出store_month_visit_time没有值得单独放置
        NSMutableArray *tempArray = [NSMutableArray array];
        int count = subLevelArray.count;
        for (int i = 0; i < count; i++) {
            WSStoreBean *storeObj = subLevelArray[i];
            if (!storeObj.store_month_visit_time.length)
            {
                [tempArray addObject:storeObj];
            }
        }
        
        for (WSStoreBean *storeObj in tempArray) {
            
            if ([subLevelArray containsObject:storeObj])
            {
                [subLevelArray removeObject:storeObj];
            }
        }
        
        //store_month_visit_time 有值得根据值排序
        for (int i = 0 ; i < subLevelArray.count; i++) {
            
            for (int j = i+1; j < subLevelArray.count; j++) {
                
                WSStoreBean *beforeStoreBean = subLevelArray[i];
                WSStoreBean *afterStoreBean = subLevelArray[j];
                if ([beforeStoreBean.store_month_visit_time intValue] > [afterStoreBean.store_month_visit_time intValue])
                {
                    [subLevelArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
        //将每个子数组中的store加入到最终使用的数组中  没值得当做是0  放在最前面
        [storeDataArray addObjectsFromArray:tempArray];
        [storeDataArray addObjectsFromArray:subLevelArray];
    }
    
    //没有等级的放最后
    [storeDataArray addObjectsFromArray:noItem_nameArray];
    return storeDataArray;
}

#pragma mark - 数据数组去重
+ (NSMutableArray *)duplicateRemoval:(NSMutableArray *)array
{
    NSMutableArray * storeArray =  [[NSMutableArray alloc]init];
    NSMutableArray * storeIdArray = [[NSMutableArray alloc]init];
    for (WSStoreBean * store in array) {
        if (![storeIdArray containsObject:store.Id])
        {
            [storeArray addObject:store];
            [storeIdArray addObject:store.Id];
        }
    }
    [array removeAllObjects];
    [array addObjectsFromArray: storeArray];
    return array;
}

#pragma mark - 获得计划内门店个数
+ (NSInteger)getInPlanNumber
{
    return allInPlanStoreCount;
}

+ (void)requestInPlanWithStoreBean:(WSStoreBean*)store successCallBack:(void(^)(id))successCallback failCallback:(void(^)(NSString *error))failCallback
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:INPLAN_UPDATA_NOTIFY
                                               object:nil];
    successBlock = successCallback;
    failCallback = failCallback;
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:@"1" forKey:@"compress"];
    [dic setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [dic setObject: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME forKey:@"objId"];
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];
    //空岗时候没有empId，传@""即可
    [dic setObject:[NSString stringNotNilWithValue:store.empId] forKey:@"empId"];
    
    [[WSRequestHelper shareInstance] uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:INPLAN_UPDATA_NOTIFY md5:nil isUpload:NO];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
}

//计划内网络数据请求开始  随访时计划内需要实时获取数据
//网络数据请求结束
-(void)finishRequest:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:INPLAN_UPDATA_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        failCallback(tmpString);
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        successBlock(uploadState);
    }
}


#pragma mark - 计划外门店网络请求
+ (void)requestOutPlanWithStoreBean:(WSStoreBean*)store successCallBack:(void(^)(id))successCallback failCallback:(void(^)(NSString *error))failCallback
{
    //请求结束和计划内公用一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:INPLAN_UPDATA_NOTIFY
                                               object:nil];
    successBlock = successCallback;
    failCallback = failCallback;
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataOutPlanInfo:store subEmpStore:nil notifyName:UPDATA_NOTIFY];
}

@end
