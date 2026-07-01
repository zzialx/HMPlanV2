//
//  WSAcvtModel.m
//  WinSFA
//
//  Created by yang on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtModel.h"
#import "WSPhotoTypeArrayItem.h"
#import "WSPhotoTypeItem.h"
#import "WidgetConstant.h"
#import "WSStoreAcvtDisBean.h"
#import "WSAcvtDisQstBean.h"
#import "WSAcvtDBService.h"
#import "WSCustomTimeTable.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSEnvrionment.h"
#import "WinSFA.h"
#import "WSBaseAcvtdisDBService.h"
#import "YYModel.h"
#import "WSEmbeddedNewAcvtViewController.h"
#import "WSNestedNewAcvtModel.h"

@implementation WSAcvtModel

- (NSMutableDictionary *)qstDBValueDictionary
{
    if (!_qstDBValueDictionary) {
        _qstDBValueDictionary = [[NSMutableDictionary alloc] init];
    }
    return _qstDBValueDictionary;
}

- (void)loadDataFromDataBase
{
    if (!self.hasLoadDataBaseData) {
        
        if ([self.qstDBValueDictionary count] > 0) {
            return;
        }
        
        if (!self.currentStore && self.currentSubEmpStore && self.currentSubEmpStore.Id) {
            if (self.md5 == nil) {
                NSDictionary* md5Param = [self md5Param];
                [self createMD5With:md5Param];
            }
        }
        
        
        if(self.subEmpId && self.subEmpId.length>0){
            if(!self.currentStore){
                self.currentStore = [[WSStoreBean alloc] init];
            }
            
            self.currentStore.srid = self.subEmpId;
            self.currentStore.storeAccessMode = WSStoreAccessModeSubEmp;
        }
        
        NSString *storeId = self.currentStore.Id;
        if (self.hosBean) {
            storeId = self.hosBean.Id;
        }else if (self.currentSubEmpStore) {
            storeId = self.currentSubEmpStore.Id;
        }
        
        NSString *newStoreId = @"";
        if (self.currentNewStore) {
            newStoreId = self.currentNewStore.Id;
        }
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        self.datasFromDB = [service queryLocalStoreAcvtDisBeanArrayWithStoreID:storeId newStoreId:newStoreId genID:self.md5 withEmpId:self.subEmpId];
        
        [self setUpQstDBValueDicWithAcvtQstObjectArray:self.datasFromDB];
        
        self.hasLoadDataBaseData = YES;
        
        if (self.datasFromDB.count > 0) {
            self.hasLocalData = YES;
        }
    }
}


- (void)setUpQstDBValueDicWithAcvtQstObjectArray:(NSArray *)array
{
    
    for (WSVisitStoreAcvtDataObject *qstObject in array) {
        NSString* qstid = qstObject.acvtqstid;
        NSString* optval = qstObject.acvt_qst_answer;
        
        if( qstid && ![qstid isEqualToString:@"<null>"] && optval)
        {
            [self.qstDBValueDictionary setObject:optval forKey:qstid];
        }
    }
    
}

- (NSString *)getAcvtDisValueWhenCreatetForPeopleByQstId:(NSString *)acvtQstId {
    if (self.isNewAddAcvt) {
        
        return [self queryPeopleQstValueByAcvtQstId:acvtQstId];
        
    }
    return nil;
}

- (NSString *)getAcvtDisValueByAcvtQstId:(NSString *)acvtQstId
{
   
    if ([self.prepareVisitDate length] > 0) {
        NSString *bizDate = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
        if (![self.prepareVisitDate isEqualToString:bizDate]) {
            return nil;
        }
    }
    
    if(self.currentNewStore && self.currentNewStore.Id!=nil && ![self.currentNewStore.Id isEqualToString:@"-1"] && ![self.currentStore.Id isEqualToString:@"-1"]){
        return [self getAcvtDisValueByStore:self.currentNewStore ByHosBean:nil acvtQstId:acvtQstId];
    }
    else if (self.currentStore && self.currentStore.Id!=nil && ![self.currentStore.Id isEqualToString:@"-1"]) {
        return [self getAcvtDisValueByStore:self.currentStore ByHosBean:self.hosBean acvtQstId:acvtQstId];
    }else{
        
        return [self queryPeopleQstValueByAcvtQstId:acvtQstId];
        
    }
    return nil;
}

- (NSString *)getAcvtDisValueByStore:(WSStoreBean *)store ByHosBean:(WSHosBean *)hosBean acvtQstId:(NSString *)acvtQstId
{
    WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = [WSBaseStoreAcvtDisTable sharedTable];
    NSMutableArray *names = [@[@"sid",@"acvtId",@"acvtQstId"]mutableCopy];
    NSString *sid = hosBean ? hosBean.Id : store.Id;
    NSMutableArray *values = [@[[NSString stringNotNilWithValue:sid],[NSString stringNotNilWithValue:self.currentAcvtBean.acvtId],[NSString stringNotNilWithValue:acvtQstId]] mutableCopy];
    
    if ([self.updateGenId length] > 0) {
        [names addObject:@"gen_id"];
        [values addObject:[NSString stringWithValue:self.updateGenId]];
    }else {
        [names addObject:@"gen_id"];
        [values addObject:[NSNull null]];
    }
    
    NSArray *querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
    
    if ([querys count] > 0) {
        
        NSArray *filterArray = querys;
        
        NSArray *answerArray = [filterArray valueForKeyPath:@"@distinctUnionOfObjects.acvt_qst_answer"];
        
        NSPredicate *predicateNotNull = [NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]];
        answerArray = [answerArray filteredArrayUsingPredicate:predicateNotNull];
        
        return [answerArray componentsJoinedByString:@","];
    }
    
    return nil;
}

- (NSString *)getAcvtDisValueByStore:(WSStoreBean *)store acvtQstId:(NSString *)acvtQstId{
    return [self getAcvtDisValueByStore:store ByHosBean:nil acvtQstId:acvtQstId];
//    WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = [WSBaseStoreAcvtDisTable sharedTable];
//    NSMutableArray *names = [@[@"sid",@"acvtId",@"acvtQstId"]mutableCopy];
//    NSMutableArray *values = [@[[NSString stringNotNilWithValue:store.Id],[NSString stringNotNilWithValue:self.currentAcvtBean.acvtId],[NSString stringNotNilWithValue:acvtQstId]] mutableCopy];
//
//    if ([self.updateGenId length] > 0) {
//        [names addObject:@"gen_id"];
//        [values addObject:[NSString stringWithValue:self.updateGenId]];
//    }else {
//        [names addObject:@"gen_id"];
//        [values addObject:[NSNull null]];
//    }
//
//    NSArray *querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
//
//    if ([querys count] > 0) {
//
//        NSArray *filterArray = querys;
//
//        NSArray *answerArray = [filterArray valueForKeyPath:@"@distinctUnionOfObjects.acvt_qst_answer"];
//
//        NSPredicate *predicateNotNull = [NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]];
//        answerArray = [answerArray filteredArrayUsingPredicate:predicateNotNull];
//
//        return [answerArray componentsJoinedByString:@","];
//    }
//
//    return nil;

}

- (NSString *)queryPeopleQstValueByAcvtQstId:(NSString *)acvtQstId
{
    WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = [WSBaseStoreAcvtDisTable sharedTable];
    NSMutableArray *names = [@[@"sid",@"acvtId",@"acvtQstId"]mutableCopy];
    NSMutableArray *values = [@[[NSNull null],[NSString stringNotNilWithValue:self.currentAcvtBean.acvtId],[NSString stringNotNilWithValue:acvtQstId]]mutableCopy];
    
    // SFA-16049 和 MSTD-7733
    NSInteger  genIdIndex = [values count];
    [names addObject:@"gen_id"];
//    SFA-18590
//    【IOS】工作-客户管理-点击筛选按钮-闪退
   // SFA-22438 zhaodanyang
    [values addObject:[NSString stringWithValue:self.md5] ? : [NSNull null]];
    
    //MN-570 2018-02-07
    NSArray *querysOne = [baseStoreAcvtDisTable queryWithNames:names ArgumentsValue:values];
    [values replaceObjectAtIndex:0 withObject:[NSNull null]];
    NSArray *querysTwo = [baseStoreAcvtDisTable queryWithNames:names ArgumentsValue:values];
    NSMutableArray *connectArray = [NSMutableArray arrayWithArray:querysOne];
    [connectArray addObjectsFromArray:querysTwo];
    NSArray *querys = (NSArray *)connectArray;
    
    if ([querys count] > 0) {
        NSArray *answerArray = [querys valueForKeyPath:@"@distinctUnionOfObjects.acvt_qst_answer"];
        NSPredicate *predicateNotNull = [NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]];
        answerArray = [answerArray filteredArrayUsingPredicate:predicateNotNull];
        return [answerArray componentsJoinedByString:@","];
    }else {
        // MSTD-7733 上一次查询没有数据， 删除 genId 的值 再查询一次 genId 为空的时候
        [values replaceObjectAtIndex:genIdIndex withObject:[NSNull null]];
        
        querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
        if ([querys count] > 0) {
            WSBaseStoreAcvtDisObject *obj = (WSBaseStoreAcvtDisObject *)[querys firstObject];
            return obj.acvt_qst_answer;
        }
    }
    
    return nil;
    
}


- (NSArray *)getAcvtDisArrayValueByAcvtQstId:(NSString*)acvtQstId
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:1];
    NSString *disValueStr = [self getAcvtDisValueByAcvtQstId:acvtQstId];
    // SFA-24970
    //备注：蒙牛分支上是用@"#"分隔的
    if ([disValueStr containsString:@"#"]) {
        array = (NSMutableArray *)[disValueStr componentsSeparatedByString:@"#"];
    } else {
        array = (NSMutableArray *)[disValueStr componentsSeparatedByString:@","];
    }
    return array;
    
}

- (BOOL)deleteAcvtDatasWithGenId:(NSString *)genId {
   return  [WSAcvtDBService deleteVisitStoreAcvtDataWithGenId:genId];
}

- (BOOL)firstLoadIsExtended:(id<I_W_BuildInfo>)buildInfo
{
    BOOL firstLoadIsExtended = YES;
    NSInteger countTB = 0;
    for (WSAcvtBean_qst* ab_qst in self.currentAcvtBean.qsts) {
        if ([ab_qst.qstType isEqualToString:QST_TYPE_TB]) {
            
            if ([[buildInfo getTabGroupName] length] > 0) {
                if ([ab_qst.tab isEqualToString:[buildInfo getTabGroupName]]) {
                    countTB++;
                }
            }else {
                countTB++;
            }
        }
    }
    if (countTB > 1) {
        firstLoadIsExtended = NO;
    }
    
    return firstLoadIsExtended;
}


-(NSDictionary*)md5Param
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[super md5Param]];
    /*Jira - MSTD-7007 没判断空,导致崩溃 create by sunhongfu 2017-11-21*/
    if (self.currentAcvtBean.acvtId.length > 0)
    {
         [dic setObject:self.currentAcvtBean.acvtId forKey:ACVT_ID];
    }
    else
    {
        NSLog(@"self.currentAcvtBean.acvtId是空");
    }
    
    
    if ([self needSoleTime]) {
        NSString* l_dateStr = [WSCurrentTime getDateTime];
        [dic setObject:l_dateStr forKey:DATE_MD5_PARAM_KEY];
    }
    
    if (self.currentAcvtBean.dateTyp && self.currentAcvtBean.dateTyp.length > 0) {
        
        NSString* l_dateStr = [WSCurrentTime getMD5TimeWithDataType:self.currentAcvtBean.dateTyp];

        [dic setObject:l_dateStr forKey:DATE_MD5_PARAM_KEY];
        
    }
    if (self.subEmpId && [self.subEmpId length] > 0) {
        [dic setObject:self.subEmpId forKey:MEMO_MD5_PARAM_KEY];
    }
    
    /*self.hosBean 和 self.subEmpId 不会同时出现*/
    if (self.hosBean && [self.hosBean.Id length] > 0) {
        [dic setObject:[NSString stringNotNilWithValue:self.hosBean.Id] forKey:MEMO_MD5_PARAM_KEY];
    }
    
    return dic;
}

- (BOOL)isFromNewAddList {
    return NO;
}

- (BOOL)needSoleTime
{
    return [self isFromNewAddList];
}

- (BOOL)isSupperChangedLocalPhoto
{
    if (self.currentStore && self.currentStore.Id)
    {
        if ([[WSCustomTimeTable sharedTable] isCustomTimeWithStoreId:self.currentStore.Id withNeedNoLeaveStore:YES withVisitId:nil] )
        {
            return YES;
        }
    }
    
    return NO;
}


- (NSString *)generateAcvtStoreNameWithQstValueDic:(NSDictionary *)qstValueDic {
    
    NSString *storeName = @"";
    
    for(WSAcvtBean_qst* ab_qst in self.currentAcvtBean.qsts)
    {
        if(ab_qst.isAcvtName && [ab_qst.isAcvtName isEqualToString:@"1"])
        {
            NSString *key = [NSString stringWithFormat:@"%@%@",ab_qst.qstType, ab_qst.acvtQstId];
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_C]||
               [ab_qst.qstType isEqualToString:QST_TYPE_R])
            {
                storeName = [NSString stringWithFormat:@"%@", [qstValueDic objectForKey:key]];
            }
            else {
                id inputVal = [qstValueDic objectForKey:key];
                if(inputVal && [inputVal isKindOfClass:[NSString class]]){
                    storeName = [storeName stringByAppendingFormat:@" %@",inputVal];
                }else if (inputVal && [inputVal isKindOfClass:[NSArray class]]) {
                    storeName = [storeName stringByAppendingFormat:@"%@",ab_qst.acvtQstId];
                }
            }
            
            //Note： djf 指定了显示名称但又不是必填项并且没有填写，则用id取代。
            if (!storeName) {
                storeName = ab_qst.acvtQstId;
            }
        }
    }
    //兼容一个调查问卷有多个ab_qst.isAcvtName为真， 此新增调查问卷名字为几个ab_qst的回显值的拼接
    if ([storeName length] > 0) {
        return storeName;
    }
    return nil;
}


/**
 *  检测是否为同步请求，默认为异步请求
 *
 *  @return BOOL
 */
-(BOOL)isSynchronizeRequest
{
    BOOL result = YES;
    
    if ([self.currentAcvtBean.isBlock isEqualToString:@"0"] || !self.currentAcvtBean.isBlock || [self.currentAcvtBean.isBlock length] == 0) {
        result = NO;
    }
    
    return result;
}


-(NSMutableArray *)DuplicateRemoval:(NSArray *)array{ // 数组去重
    
    NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
    for (WSBaseStoreAcvtDisObject * object in array) {
        
        [dict setObject:object forKey:object.gen_id];
    }
    NSMutableArray * query = [NSMutableArray arrayWithCapacity:0];
    NSArray * allkeys = [dict allKeys];
    for (NSString  *str in allkeys) {
        [query addObject:[dict objectForKey:str]];
    }
    
    return query;
}

- (BOOL)isNeedNewImageIndex {
    
    if ((self.isSubAcvt && [self.currentFuncs.opt.isUseNewId isEqualToString:SUB_ACVT_USER_NEWID])
        || [self.currentFuncs.opt.isUseNewId isEqualToString:@"E"]) {
        return YES;
    }
    
    return NO;
}










#pragma mark - 保存调查问卷数据方法
- (BOOL)saveAcvtDatasToDB:(NSDictionary *)dataDic useNewMd5:(NSString *)newMd5 {
    
    return [self operateSaveAcvtDatasToDB:dataDic useNewMd5:newMd5];
}

#pragma mark - 操作保存调查问卷数据方法
- (BOOL)operateSaveAcvtDatasToDB:(NSDictionary *)dataDic useNewMd5:(NSString *)newMd5 {
    
    if (self.subEmpId && self.subEmpId.length > 0) {
        
        if (!self.currentStore) {
            self.currentStore = [[WSStoreBean alloc] init];
        }
        self.currentStore.srid = self.subEmpId;
        self.currentStore.storeAccessMode = WSStoreAccessModeSubEmp;
    }
    
    id store = self.currentStore;
    if (self.hosBean) {
        store = self.hosBean;
    }
    if (self.currentSubEmpStore) {
        store = self.currentSubEmpStore;
    }
    
    NSString *md5 = ([newMd5 length] > 0) ? newMd5 : self.md5;
    NSString *bizDate = self.prepareVisitDate ? self.prepareVisitDate : [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    return [WSAcvtDBService insertAcvtDatasToDBWithStore:store newStoreBean:self.currentNewStore acvtBean:self.currentAcvtBean qstValueDic:dataDic
                                      qstValueDicKeyType:WSAcvtQstValueDicKeyTypeQstTypeAndAcvtqstID funcCod:self.currentFuncs.fc md5:md5 bizDate:bizDate];
}

#pragma mark - 获取进入后台存储调查问卷数据标识(开关)方法
- (BOOL)getEnterBackgroundSaveAcvtDataMark {
    
    if ([self.currentFuncs.opt.isBackgroundCache isEqualToString:@"1"]) {
        
        if ([self isKindOfClass:[WSNestedNewAcvtModel class]]) {
            return NO;
        }
        
        if (self.ownAcvtViewController && [self.ownAcvtViewController isKindOfClass:[WSEmbeddedNewAcvtViewController class]]) {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - 进入后台保存调查问卷数据方法(不单独做开关判断 只是逻辑设定 开关由外界调用判断-牵扯表格数据/照片数据保存)
- (BOOL)enterBackgroundSaveAcvtDatasToDB:(NSDictionary *)dataDic useNewMd5:(NSString *)newMd5
                                   vcMd5:(NSString *)vcMd5 vcUpdateGenId:(NSString *)vcUpdateGenId {
    
    BOOL isSaveSuccess = [self operateSaveAcvtDatasToDB:dataDic useNewMd5:newMd5];
    LogInfo(@"WSAcvtModel enterBackgroundSaveAcvtDatasToDB:useNewMd5:vcMd5:vcUpdateGenId: isSaveSuccess = %@", (isSaveSuccess ? @"YES" : @"NO"));
    if (!isSaveSuccess) {
        return isSaveSuccess;
    }
    
    NSString *empid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *storeid = [NSString stringNotNilWithValue:self.currentStore.Id];
    NSString *acvtid = [NSString stringNotNilWithValue:self.currentAcvtBean.acvtId];
    NSString *md5Key = [NSString stringNotNilWithValue:(([newMd5 length] > 0) ? newMd5 : self.md5)];
    NSString *dicKey = [NSString stringWithFormat:@"%@_%@_%@_%@_%@", empid, bizdate, storeid, acvtid, md5Key];
    LogInfo(@"WSAcvtModel enterBackgroundSaveAcvtDatasToDB:useNewMd5:vcMd5:vcUpdateGenId: dicKey = %@", dicKey);
    if (empid.length == 0 || bizdate.length == 0 || storeid.length == 0 || acvtid.length == 0 || md5Key.length == 0) {
        return NO;
    }
    
    WinEnterBackgroundDataModel *model = [[WinEnterBackgroundDataModel alloc] init];
    model.vcMd5 = [NSString stringNotNilWithValue:vcMd5];
    model.vcUpdateGenId = [NSString stringNotNilWithValue:vcUpdateGenId];
    model.modelMd5 = [NSString stringNotNilWithValue:(([newMd5 length] > 0) ? newMd5 : self.md5)];
    model.modelUpdateGenId = [NSString stringNotNilWithValue:self.updateGenId];
    NSString *jsonStr = [model yy_modelToJSONString];
    LogInfo(@"WSAcvtModel enterBackgroundSaveAcvtDatasToDB:useNewMd5:vcMd5:vcUpdateGenId: jsonStr = %@", jsonStr);
    
    id enterBackgroundAcvtMarkDicObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterBackgroundAcvtMarkDic"];
    if ([enterBackgroundAcvtMarkDicObj isKindOfClass:[NSDictionary class]]) {

        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)enterBackgroundAcvtMarkDicObj];
        [newDic setObject:jsonStr forKey:dicKey];
        [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"enterBackgroundAcvtMarkDic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return YES;
    }
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [newDic setObject:jsonStr forKey:dicKey];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"enterBackgroundAcvtMarkDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

#pragma mark - 查询进入后台标识方法
- (WinEnterBackgroundDataModel *)queryEnterBackgroundMark {
    
    BOOL isOpenEnterBackground = [self getEnterBackgroundSaveAcvtDataMark];
    if (!isOpenEnterBackground) {
        return nil;
    }
    
    NSString *empid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *storeid = [NSString stringNotNilWithValue:self.currentStore.Id];
    NSString *acvtid = [NSString stringNotNilWithValue:self.currentAcvtBean.acvtId];
    NSString *dicKey = [NSString stringWithFormat:@"%@_%@_%@_%@", empid, bizdate, storeid, acvtid];
    LogInfo(@"WSAcvtModel queryEnterBackgroundMark: dicKey = %@", dicKey);
    if (empid.length == 0 || bizdate.length == 0 || storeid.length == 0 || acvtid.length == 0) {
        return nil;
    }
    
    id enterBackgroundAcvtMarkDicObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterBackgroundAcvtMarkDic"];
    if ([enterBackgroundAcvtMarkDicObj isKindOfClass:[NSDictionary class]]) {
    
        NSString *modelStr = nil;
        NSString *cacheKey = nil;
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)enterBackgroundAcvtMarkDicObj];
        for (int i = 0; i < newDic.allKeys.count; i++) {
            
            NSString *key = [newDic.allKeys objectAtIndex:i];
            if ([key hasPrefix:dicKey]) {
                
                cacheKey = key;
                modelStr = [newDic objectForKey:key];
                LogInfo(@"WSAcvtModel queryEnterBackgroundMark modelStr = %@", modelStr);
                break;
            }
        }
        
        if (!modelStr) {
            return nil;
        }
        
        WinEnterBackgroundDataModel *model = [WinEnterBackgroundDataModel yy_modelWithJSON:modelStr];
        
        NSString *sql = [NSString stringWithFormat:@"select count(_id) from visit_store_acvt_data where emp_id = '%@' and biz_date = '%@' and sid = '%@' and acvtId = '%@' and gen_id = '%@'", empid, bizdate, storeid, acvtid, model.modelMd5];
        WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
        NSInteger count = [sqliteUtil queryCountWithSql:sql];
        if (count == 0) {
            
            [newDic removeObjectForKey:cacheKey];
            
            if (newDic.allKeys.count > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"enterBackgroundAcvtMarkDic"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"enterBackgroundAcvtMarkDic"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            return nil;
        }
        
        return model;
    }
    
    return nil;
}

#pragma mark - 通过md5清除进入后台标识
+ (void)clearEnterBackgroundMarkWithMD5:(NSString *)md5 {

    if (md5.length == 0) {
        return;
    }
    
    NSArray *separatedArray = [md5 componentsSeparatedByString:@"_"];
    NSString *markStr = [NSString stringNotNilWithValue:separatedArray.lastObject];
    LogInfo(@"WSAcvtModel clearEnterBackgroundMarkWithMD5 md5 = %@ markStr = %@", md5, markStr);
    
    id enterBackgroundAcvtMarkDicObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterBackgroundAcvtMarkDic"];
    if ([enterBackgroundAcvtMarkDicObj isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)enterBackgroundAcvtMarkDicObj];
        LogInfo(@"WSAcvtModel clearEnterBackgroundMarkWithMD5 newDic = %@", newDic);
        
        for (int i = 0; i < newDic.allKeys.count; i++) {
            
            NSString *dicKey = [newDic.allKeys objectAtIndex:i];
            if ([dicKey hasSuffix:markStr]) {
                
                [newDic removeObjectForKey:dicKey];
                LogInfo(@"WSAcvtModel clearEnterBackgroundMarkWithMD5 removeKey = %@", dicKey);
                
                break;
            }
        }
        
        if (newDic.allKeys.count > 0) {
            
            [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"enterBackgroundAcvtMarkDic"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"enterBackgroundAcvtMarkDic"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - 清除日期后台标识
+ (void)claerDateEnterBackgroundMark {
    
    id enterBackgroundAcvtMarkDicObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterBackgroundAcvtMarkDic"];
    if ([enterBackgroundAcvtMarkDicObj isKindOfClass:[NSDictionary class]]) {
        
        NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)enterBackgroundAcvtMarkDicObj];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT self CONTAINS %@", bizdate];
        NSArray *filteredArray = [newDic.allKeys filteredArrayUsingPredicate:predicate];
        LogInfo(@"WSAcvtModel claerDateEnterBackgroundMark newDic.allKeys = %@ filteredArray = %@", newDic.allKeys, filteredArray);
        
        if (filteredArray.count == 0) {
            return;
        }
        
        [newDic removeObjectsForKeys:filteredArray];
        LogInfo(@"WSAcvtModel claerDateEnterBackgroundMark newDic = %@", newDic);
        
        if (newDic.allKeys.count > 0) {
            
            [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"enterBackgroundAcvtMarkDic"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"enterBackgroundAcvtMarkDic"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - 清除全部后台标识
+ (void)claerAllEnterBackgroundMark {
    
    LogInfo(@"WSAcvtModel claerAllEnterBackgroundMark");
    
    id enterBackgroundAcvtMarkDicObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterBackgroundAcvtMarkDic"];
    if ([enterBackgroundAcvtMarkDicObj isKindOfClass:[NSDictionary class]]) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"enterBackgroundAcvtMarkDic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 设置md5属性方法
- (void)setMd5:(NSString *)md5 {

    WinEnterBackgroundDataModel *model = [self queryEnterBackgroundMark];
    if (model) {
        
        [super setMd5:model.modelMd5];
        return;
    }

    [super setMd5:md5];
}

#pragma mark - 设置updateGenId属性方法
- (void)setUpdateGenId:(NSString *)updateGenId {
    
    WinEnterBackgroundDataModel *model = [self queryEnterBackgroundMark];
    if (model) {

        _updateGenId = model.modelUpdateGenId;
        return;
    }

    _updateGenId = updateGenId;
}

@end

@implementation WinEnterBackgroundDataModel

@end
