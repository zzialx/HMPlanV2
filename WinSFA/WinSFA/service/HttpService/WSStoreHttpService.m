//
//  WSStoreHttpService.m
//  WinSFA
//
//  Created by yang on 17/3/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreHttpService.h"
#import "WSRequestHelper.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSStoreDataProcessService.h"
#import "WSBaseStoreTable.h"
#import "WSBaseAcvtDBService.h"
#import "NSDictionary+Additional.h"
#import "WSBaseAcvtdisDBService.h"
#define kStoreHttpServiceNotifyName @"kStoreHttpServiceNotifyName"
#define kGetStoreListDataWithParamsNotifyName @"kGetStoreListDataWithParamsNotifyName"

@interface WSStoreHttpService ()

@property (nonatomic, copy) WSBaseHttpServiceBlock completionBlock;

@end

@implementation WSStoreHttpService

-(NSDictionary * )getParam{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:self.storeBean.Id] forKey:@"storeId"];
    NSString * objId = self.objID;
    if (!objId) {
        objId = ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    }
    [outPlan setObject:objId forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:self.jsEmpID] forKey:@"empId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];//辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台
    NSString * bizDate = self.bizDate;
    if (bizDate) {
        [outPlan setObject:bizDate forKey:@"bizDate"];
    }

    return outPlan;
}
-(NSDictionary *)getRequestStoreListParams
{
    NSMutableDictionary* l_dic = [[NSMutableDictionary alloc]init];
    if (self.isUploadLocationInfo) {
        [l_dic setObject:[NSString stringNotNilWithValue:self.searchString] forKey:CQ_KEYWORD];
        [l_dic setObject:[[NSNumber numberWithDouble:self.location.latitude] stringValue] forKey:GPS_LAT];
        [l_dic setObject:[[NSNumber numberWithDouble:self.location.longitude] stringValue] forKey:GPS_LON];
        NSString *currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:SELECTED_CITY_NAME];
        if (!currentCity) {
            currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];;
        }
        [l_dic setObject:[NSString stringNotNilWithValue:currentCity] forKey:GEONAME];
    }
    if ([self.cityCode length] > 0) {
        [l_dic setObject:self.cityCode forKey:@"cityCode"];
    } else if ([self.orgId length] > 0) {
        [l_dic setObject:self.orgId forKey:@"orgId"];
    }
    NSString * empId = self.subEmpStoreBean.Id ? self.subEmpStoreBean.Id : [WSAppData getObjectbyKey:APPDATA_EMPID];
    [l_dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [l_dic setObject:@"1" forKey:@"compress"];
    [l_dic setObject:self.objID forKey:@"objId"];
    [l_dic setObject:@"no cellid" forKey:@"cellId"];
    [l_dic setObject:[NSString stringNotNilWithValue:self.searchString] forKey:@"name"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:USERNAME_LAST_LOGIN];
    [l_dic setObject:[NSString stringNotNilWithValue:userName] forKey:@"userId"];
    if (self.currentFunc.styp  && [self.currentFunc.styp length] > 0) {
        [l_dic setObject:[NSString stringNotNilWithValue:self.currentFunc.styp] forKey:@"styp"];
    }
    if (self.currentFunc.sqlw && self.currentFunc.sqlw.length > 0) {
        [l_dic setObject:[NSString stringNotNilWithValue:self.currentFunc.sqlw] forKey:@"sqlw"];
    }
    if (self.distance) {
        [l_dic setObject:[NSString stringWithFormat:@"%.1lf",self.distance] forKey:@"JL-PWK"];
    }
    
    //YIHAIKERRY-2888 2018-05-29
    if (self.maxLat > 0) [l_dic setObject:[[NSNumber numberWithDouble:self.maxLat] stringValue] forKey:@"maxLat"];
    if (self.minLat > 0) [l_dic setObject:[[NSNumber numberWithDouble:self.minLat] stringValue] forKey:@"minLat"];
    if (self.maxLon > 0) [l_dic setObject:[[NSNumber numberWithDouble:self.maxLon] stringValue] forKey:@"maxLon"];
    if (self.minLon > 0) [l_dic setObject:[[NSNumber numberWithDouble:self.minLon] stringValue] forKey:@"minLon"];

    if (self.searchConditionDic.count > 0)
    {
        //MN-2509需要放开 注释掉以下逻辑(只放开 [l_dic addEntriesFromDictionary:searchConditionDic];) 两个功能点有冲突 后续开发MN-2509在讨论
        //[l_dic addEntriesFromDictionary:self.searchConditionDic];
        
        //MN-1911 主管反馈-三个筛选按钮，筛选无效
        NSArray *allkey = [self.searchConditionDic allKeys];
        WSBaseAcvtDBService *dbSerVice = [[WSBaseAcvtDBService alloc] init];
        
        //MN-3131【IOS】闪退！//存取不一致导致
        for (NSString *acvtQstCode in allkey){
            
            //MN-3410 修改逻辑
            WSAcvtBean_qst *qst = [dbSerVice queryQstWithAcvtQstCode:acvtQstCode];
            if(!qst){
                qst = [dbSerVice queryQstWithAcvtQstId:acvtQstCode];
            }
            if(qst){
                [l_dic setObject:[self.searchConditionDic objectForKey:acvtQstCode] forKey:qst.qstCod];
            }
        }
    }
    
    return l_dic;
}

- (void)getOutplanStoreDataWithCompletionBlock:(WSBaseHttpServiceBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:kStoreHttpServiceNotifyName
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr uploadDatasDictionary:[self getParam] urlString:URL_UPDATE notifyName:kStoreHttpServiceNotifyName md5:nil isUpload:NO];

}

- (void)getCustomerQueryStoreListDataWithParams:(NSDictionary *)dic withCompletionBlock:(WSBaseHttpServiceBlock)completionBlock{
    
    self.completionBlock = completionBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getStoreListFinishRequest:)
                                                 name:kGetStoreListDataWithParamsNotifyName
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:kGetStoreListDataWithParamsNotifyName md5:nil isUpload:NO];
}
- (void)getCustomerQueryStoreListDataWithCompletionBlock:(WSBaseHttpServiceBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getStoreListFinishRequest:)
                                                 name:kGetStoreListDataWithParamsNotifyName
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr uploadDatasDictionary:[self getRequestStoreListParams] urlString:URL_UPDATE notifyName:kGetStoreListDataWithParamsNotifyName md5:nil isUpload:NO];
}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kStoreHttpServiceNotifyName
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        if (self.completionBlock) {
            self.completionBlock(nil, error);
            self.completionBlock = nil;
        }
        
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        NSDictionary *dataInfo = uploadState;
        NSArray *allKeys = [dataInfo allKeys];
        BOOL isHasPrefix = NO;
        for (NSString *key in allKeys) {
            if ([key hasPrefix:STOREACVTDIS] || [key hasPrefix:ACVTDIS]) {
                isHasPrefix = YES ;
            }
        }
        
        NSString *objId = self.objID;
        if (!objId) {
            objId = ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
        }
        if (isHasPrefix) {
        }else{
            dataInfo = [dataInfo[objId] firstObject];
        }
        
        NSObject *tmpObject = dataInfo;
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
            storeDicInfo = [(NSArray *)tmpObject firstObject];
        }
        if(self.storeBean != nil){
            [self.storeBean reSetStore:uploadState Key:objId];
                
                [WSStoreDataProcessService processStoreInfoDataToDbWith:self.storeBean info:storeDicInfo];
                NSString *empId = ([self.subEmpStoreBean.Id length] > 0 )?self.subEmpStoreBean.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
                [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.storeBean.Id ];
        }

        if (self.completionBlock) {
            self.completionBlock(uploadState, nil);
            self.completionBlock = nil;
        }
    }
}
- (void)handleDataToDBWithAsync:(id)sender  {
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        //dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            
            NSString *tmpString = NSLocalizedString(@"network_failure",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            if (self.completionBlock) {
                self.completionBlock(nil, error);
                self.completionBlock = nil;
            }
            return;
        //});
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        
        // SFA 玛氏 MMSH-1318  因标准产品手机端默认搜索的是全部门店，所以玛氏日本做个性化处理，如果没有输入关键字搜索，提示由后台返回。后台返回的数据结构固定。所以按后台给的结构解析。
        NSArray * tipsArray = [uploadState objectForKey:@"All Store"];
        if (tipsArray.count > 0) {
            
            NSDictionary * tips = [tipsArray firstObject];
            if ([[tips objectForKey:@"tipsMsg"] length] > 0) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[tips objectForKey:@"tipsMsg"] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    if (self.completionBlock) {
                        self.completionBlock(nil, error);
                        self.completionBlock = nil;
                    }
                    return;
                //});
                
            }
        }
        
        NSArray* l_stores = [uploadState objectForKey:self.objID];

        NSString * search_ObjCode_Code = @"";
        //    if (_locationBtn.titleLabel.text && _locationBtn.titleLabel.text.length >0) {
        //    search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:_locationBtn.titleLabel.text];
        
        if (self.currentCity && self.currentCity.length >0) {
            search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:self.currentCity];
        }
        
        //YIHAIKERRY-3442 200门店时，搜索走本地，请求时全部返回， 插入数据库时，不加searchString；
        if (![self.currentFunc.opt.downByMap isEqualToString:@"2"]) {
            if (self.searchString && self.searchString.length > 0) {
                search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:self.searchString];
            }
        }
        // 如果是 只显示服务器的和自动搜索的，需要加上时间戳作为条件用来保证每次回显的都是回显后台下发的。而不是按节点和搜索条件删除门店
        if ([self.currentFunc.opt.isSearchable isEqualToString:kIsSearchAbleRemote] || [self.currentFunc.opt.isSearchable isEqualToString:kIsSearchAbleAuto]) {
            NSString  *timeString = [WSCurrentTime getTimestampString];
            search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:timeString];
        }
        
        //SFA-24817
        //和安卓统一把筛选条件拼上
        if (self.filterString && self.filterString.length > 0) {
            search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:self.filterString];
        }

        // 每次请求下来的数据，要先计算经纬度再入库
        NSMutableArray * allStores = [NSMutableArray arrayWithCapacity:l_stores.count];
        CLLocation * currentLocatin = [[CLLocation alloc]initWithLatitude:self.location.latitude longitude:self.location.longitude];
        for (NSDictionary * dic in l_stores) {
            @autoreleasepool {
                //MN-3539
                //iOS-城市经理-四级拜放-点击右上角漏斗筛选不出来门店
                NSString *jsonType = [dic objectForKey:@"jsonType"];
                NSArray *subl_stores = [dic objectForKey:self.objID];
                if (subl_stores && [jsonType isEqualToString:@"array"]) {
                    for (NSDictionary *subDict in subl_stores) {
                        [allStores addObject:[self requestedTheData:subDict currentLocatin:currentLocatin]];
                    }
                    NSString *serverNode = STOREACVTDIS;
                    for (NSString *key in [dic allKeys]) {
                        if ([key hasPrefix:@"acvtdis"] || [key hasSuffix:@"acvtdis"]) {
                            serverNode = key;
                        }
                    }
                    //保存下发的回显数据
                    NSArray *storeacvtdis = [dic objectForKey:serverNode];
                    WSBaseAcvtdisDBService *baseAcvtDisSerice = [[WSBaseAcvtdisDBService alloc] init];
                    [baseAcvtDisSerice replaceToTableWithDicts:storeacvtdis FromNode:serverNode hasNewData:YES storeID:self.storeBean.Id];
                    
                } else {
                    
                    [allStores addObject:[self requestedTheData:dic currentLocatin:currentLocatin]];
                }
            }
        }
        
        [[WSBaseStoreTable sharedTable] insertAllStoresWith:allStores searchObjId:self.objID searchObjCode:search_ObjCode_Code isPlan:@"0"];
        NSString * empId = self.subEmpStoreBean.Id ? self.subEmpStoreBean.Id : [WSAppData getObjectbyKey:APPDATA_EMPID];
        NSString *funCode = self.currentFunc.fc;
        if (self.subMenuFuncsCode) {
            funCode = self.subMenuFuncsCode;
        }
        [WSBaseStoreOtherDataDBService saveStoreSearchObjCode:search_ObjCode_Code flagWith:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcCode:funCode];
        if(allStores.count > 0)
        {
            NSString *cityCode = self.cityCode.length > 0 ? self.cityCode : self.orgId;
            NSString *cityName = self.cityCode.length > 0 ? self.currentCity : self.currentOrg;
            
            [WSBaseStoreOtherDataDBService saveStoreCityCode:cityCode cityName:cityName empId:empId bizDate:[WSCurrentTime getTimestampString] storeCount:[NSString stringWithFormat:@"%ld",allStores.count] type:self.downLoadStoreListType];

        }
        //dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completionBlock) {
            self.completionBlock(uploadState, error);
            self.completionBlock = nil;
        }
        //});
    }
   
}
//把请求下来的数据，计算经纬度返回
- (NSMutableDictionary *)requestedTheData:(NSDictionary *)dic currentLocatin:(CLLocation *)currentLocatin
{
    NSMutableDictionary  *tempDic = dic.mutableCopy;
    NSString *lon = [NSString stringNotNilWithValue:dic[Store_lon]];
    NSString *lat = [NSString stringNotNilWithValue:dic[Store_lat]];
    
    if (![lon isEqualToString:@"0"] && ![lat isEqualToString:@"0"] && lon.length > 0 && lat.length > 0 &&
        (currentLocatin.coordinate.longitude > 0 && currentLocatin.coordinate.latitude > 0)) {
        CLLocation *storeLocation = [[CLLocation alloc]initWithLatitude:[dic[Store_lat] doubleValue] longitude:[dic[Store_lon] doubleValue]];
        double f_distance= [[WSLocationManager getInstance] distanceUserLocattion:currentLocatin fromStoreLocation:storeLocation];
        [tempDic setObject:[NSString stringWithFormat:@"%.0f", f_distance] forKey:Store_distance];
    }
    
    if ([self.cityCode length] > 0) {
        [tempDic setObject:self.cityCode forKey:Store_cityId];
    } else if ([self.orgId length] > 0) {
        [tempDic setObject:self.orgId forKey:Store_orgId];
    }
    
    return tempDic;
}
-(void)getStoreListFinishRequest:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGetStoreListDataWithParamsNotifyName
                                                  object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code == 0) { //成功才通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kGetStoreListData" object:nil];
    }
    
    //异步处理数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleDataToDBWithAsync:sender];
    });
}

@end
