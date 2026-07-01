//
//  WSInoutStoreTable.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSInoutStoreTable.h"


@implementation WSInoutStoreTable


static WSInoutStoreTable *m_inout_storeTable=nil;
+ (WSInoutStoreTable *)sharedTable
{
    if (m_inout_storeTable==nil) {
        
        m_inout_storeTable = [[WSInoutStoreTable alloc]init];
    }
    return  m_inout_storeTable;
}

-(NSArray*) queryStoreVisitHistoryWithStoreBean:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType {
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]])
    {
        entryid = store.Id;
    }
    else
    {
        LogInfo(@"判断是否进店出现错误：entryid为空");
        entryid = @"";
    }
    NSArray *selectedDataArr = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            if (!parameter) {
                return [NSArray array];
            }
            
            selectedDataArr = [self queryPrentTypeWithNames:@[@"store_id",@"emp_id",@"modulefc"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
            
        }
            break;
        case EParameterType_VisitId:
        {
            if (!parameter) {
                return [NSArray array];
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        default:
        {
        
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID]]];
        }
            break;
    }
    
    return selectedDataArr;
}

//是否进店
-(BOOL)isEnterStore:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType{
    
    NSArray *selectedDataArr = [self queryStoreVisitHistoryWithStoreBean:store andOtherParam:parameter andParamType:pType];

    if ([selectedDataArr count]==0){
        return NO;
    }else{
        NSString *enterStoreTime = nil;
        for (int i=0; i<[selectedDataArr count]; i++)
        {
            WSInoutStoreObject *temp=[selectedDataArr objectAtIndex:i];
            enterStoreTime= temp.intime;
        }
        if (enterStoreTime==nil || [enterStoreTime isEqualToString:@"null"])
        {
            return NO;
        }
        return YES;
    }
}

//是否离店
-(BOOL)isLeaveStore:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType
{
    NSArray*selectedDataArr = [self queryStoreVisitHistoryWithStoreBean:store andOtherParam:parameter andParamType:pType];
    
    if ([selectedDataArr count]==0) {
        return NO;
    }else {
        NSString *leaveStoreTime = nil;
        for (int i=0; i<[selectedDataArr count]; i++) {
            WSInoutStoreObject*temp=[selectedDataArr objectAtIndex:i];
            leaveStoreTime= temp.outtime;
        }
        if (leaveStoreTime == nil || [leaveStoreTime isEqualToString:@"null"]) {
            return NO;
        }else{
            return YES;
        }
    }
}

//- (NSArray *)getEnterAndisLeaveStatusWithStore:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType
//{
//    NSArray*selectedDataArr = [self queryStoreVisitHistoryWithStoreBean:store andOtherParam:parameter andParamType:pType];
////    NSMutableArray *resultArray =
////    if (selectedDataArr) {
////        WSInoutStoreObject*temp=[selectedDataArr lastObject];
////        if (temp) {
////            NSString *enterStoreTime = temp.intime;
////            NSString *leaveStoreTime = temp.outtime;
////            if (enterStoreTime && ![enterStoreTime isEqualToString:@"null"] && leaveStoreTime && ![leaveStoreTime isEqualToString:@"null"]) {
////                return YES;
////            }
////        }
////    }
//
//}

//是否完成了一次拜访
-(BOOL) isEnterAndLeaveStore:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType {
    NSArray*selectedDataArr = [self queryStoreVisitHistoryWithStoreBean:store andOtherParam:parameter andParamType:pType];
    
    if (selectedDataArr) {
        WSInoutStoreObject*temp=[selectedDataArr lastObject];
        if (temp) {
            NSString *enterStoreTime = temp.intime;
            NSString *leaveStoreTime = temp.outtime;
            if (enterStoreTime && ![enterStoreTime isEqualToString:@"null"] && leaveStoreTime && ![leaveStoreTime isEqualToString:@"null"]) {
                return YES;
            }
        }
    }
    
    return NO;
}

//返回进店后未离开的店
-(WSInoutStoreObject*)anyStorehaveNotLeave{
    NSString* empid=[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //    NSArray*selectedDataArr=[self queryWithNames:@[@"outtime",@"emp_id"] ArgumentsValue:@[@"null",empid]];
    //MMSH-10000  未离店的判断，要在主数据中有数据
//    NSString * sql =[NSString stringWithFormat:@"select  inouttable.* from wch_inoutStore inouttable  join ws_base_store_table bst on bst.store_Id =  inouttable.STORE_ID ／* and bst.empid = inouttable.emp_id *／where inouttable.outtime = 'null'  and inouttable.emp_id='%@' and inouttable.needTip = 'null' ",empid];
//    SFA-30972
    NSString * sql =[NSString stringWithFormat:@"select  inouttable.* ,bst.name from wch_inoutStore inouttable  join ws_base_store_table bst on bst.store_Id =  inouttable.STORE_ID where inouttable.outtime = 'null'  and inouttable.emp_id='%@' and inouttable.needTip = 'null' ",empid];

    
    NSMutableArray *queryDictArr=[[NSMutableArray alloc]init];
    
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    NSString* className=[[[[self className] componentsSeparatedByString:@"Table"] firstObject] stringByAppendingString:@"Object"];
    
    while ([rs next]) {
        id object=[[NSClassFromString(className) alloc] init];
        for(int i=0;i<rs.columnCount;i++){
            
            if([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"id"] || [[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"_id"]){
                
                if ([object isKindOfClass:[WSBaseFunsObject class]]) {
                    [object setId:[rs stringForColumnIndex:i]];
                }else
                    [object setID:[rs intForColumnIndex:i]];
            }else if([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"parent_action_id"]){
                
                [object setParent_action_id:[rs intForColumnIndex:i]];
            }else{
                
                NSString* string=[rs stringForColumnIndex:i];
                if(string && string.length>0){
                    NSString* columnName=[[rs columnNameForIndex:i] lowercaseString];
                    [object setValue:string forKey:columnName];
                }
            }
            
        }
        [queryDictArr addObject:object];
    }
    
    
    if ([queryDictArr count]>0) {
        return [queryDictArr firstObject];
    }
    
    return nil;
}

-(WSInoutStoreObject*)getNotLeaveStoreByStoreId:(NSString *)storeId moduleFc:(NSString *)moduleFc{
    
    if (!storeId) {
        return nil;
    }
    
    NSString *empid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[@"outtime",@"emp_id",@"store_id"]];
    NSMutableArray *valueArray = [NSMutableArray arrayWithArray:@[@"null",empid,storeId]];
//    SFA-33717 不同模块下的互访引起的问题
//    if ([moduleFc length] > 0) {
//        [nameArray addObject:@"modulefc"];
//        [valueArray addObject:moduleFc];
//    }
    
    NSArray *selectedDataArr = [self queryWithNames:nameArray ArgumentsValue:valueArray];
    
    if ([selectedDataArr count]>0) {
        if ([selectedDataArr count] > 1) {
            for (WSInoutStoreObject *inOut in selectedDataArr) {
                if ([inOut.modulefc isEqualToString:moduleFc]) {
                    return inOut;
                }
            }
        }
        return [selectedDataArr firstObject];
    }
    
    return nil;
}


//store传过来的是storeid ,离店时间
-(NSString*)getLeaveStoreTime:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType{
    
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]]) {
        entryid = store.Id;
    }else{
        entryid = @"";
    }
    NSArray *selectedDataArr= nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            if (!parameter) {
                return nil;
            }
            selectedDataArr = [self queryPrentTypeWithNames:@[@"store_id",@"emp_id",@"modulefc"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        case EParameterType_VisitId:
        {
            if (!parameter) {
                return nil;
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        default:
        {
            
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID]]];
        }
            break;
    }
    
    NSString *leaveStoreTime=nil;
    for (int i=0; i<[selectedDataArr count]; i++) {
        WSInoutStoreObject *temp = [selectedDataArr objectAtIndex:i];
        leaveStoreTime = temp.outtime;
    }
    
    return leaveStoreTime;
}


//store传过来的是storeid ,进店时间
-(NSString*)getEnterStoreTime:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType{
    
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]]) {
        entryid = store.Id;
    }else{
        entryid = @"";
    }
    
    NSArray *selectedDataArr = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            if (!parameter) {
                return nil;
            }
            selectedDataArr = [self queryPrentTypeWithNames:@[@"store_id",@"emp_id",@"modulefc"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        case EParameterType_VisitId:
        {
            if (!parameter) {
                return nil;
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        default:
        {
            
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID]]];
        }
            break;
    }
    
    NSString *enterStoreTime=nil;
    for (int i=0; i<[selectedDataArr count]; i++) {
        WSInoutStoreObject*temp=[selectedDataArr objectAtIndex:i];
        enterStoreTime=temp.intime;
    }
     
     return enterStoreTime;
}


//更改离店时间
-(void)updateLeaveStoreTime:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType
{
    
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]]) {
        entryid = store.Id;
    }else{
        entryid = @"";
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *selectedDataArr = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            if (!parameter) {
                return;
            }
            selectedDataArr = [self queryPrentTypeWithNames:@[@"store_id",@"emp_id",@"modulefc"] ArgumentsValue:@[entryid, empId, parameter]];
        }
            break;
        case EParameterType_VisitId:
        {
            if (!parameter) {
                return;
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,empId , parameter]];
        }
            break;
        default:
        {
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id"] ArgumentsValue:@[entryid,empId]];
        }
            break;
    }
    
    NSString *enterStoreTime=nil;
    for (int i=0; i<[selectedDataArr count]; i++) {
        WSInoutStoreObject*temp=[selectedDataArr objectAtIndex:i];
        enterStoreTime=temp.intime;
    }

    NSArray *whereNames = nil;
    NSArray *whereValues = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", @"modulefc", nil];
            whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId,parameter, nil];
        }
            break;
        case EParameterType_VisitId:
        {
            
            whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", @"VISIT_ID", nil];
            whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId,parameter, nil];
        }
            break;
        default:
        {
            whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", nil];
            whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId, nil];
        }
            break;
    }
    NSArray *setNames=[NSArray arrayWithObjects:@"outtime", nil];
    
    NSArray *setValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:enterStoreTime], nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
}

-(void)updateLeaveStoreTime:(WSStoreBean*)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType outTime:(NSString*)outTime{
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]]) {
        entryid = store.Id;
    }else{
        entryid = @"";
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *selectedDataArr = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            if (!parameter) {
                return;
            }
            selectedDataArr = [self queryPrentTypeWithNames:@[@"store_id",@"emp_id",@"modulefc"] ArgumentsValue:@[entryid, empId, parameter]];
        }
            break;
        case EParameterType_VisitId:
        {
            if (!parameter) {
                return;
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,empId , parameter]];
        }
            break;
        default:
        {
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id"] ArgumentsValue:@[entryid,empId]];
        }
            break;
    }
    
    NSString *enterStoreTime=nil;
    for (int i=0; i<[selectedDataArr count]; i++) {
        WSInoutStoreObject*temp=[selectedDataArr objectAtIndex:i];
        enterStoreTime=temp.intime;
    }

    NSArray *whereNames = nil;
    NSArray *whereValues = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", @"modulefc", nil];
            whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId,parameter, nil];
        }
            break;
        case EParameterType_VisitId:
        {
            
            whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", @"VISIT_ID", nil];
            whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId,parameter, nil];
        }
            break;
        default:
        {
            whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", nil];
            whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId, nil];
        }
            break;
    }
    NSArray *setNames=[NSArray arrayWithObjects:@"outtime", nil];
    
    if(outTime){
        enterStoreTime = [WSCurrentTime getServerTime];
    }
    
    NSArray *setValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:enterStoreTime], nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
}

-(void)updateLeaveStoreTime:(NSString*)storeId andOtherParam:(NSString *)parameter
{
    NSString *entryid = storeId;

    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSArray *whereNames = nil;
    NSArray *whereValues = nil;
    whereNames = [NSArray arrayWithObjects:@"store_id", @"emp_id", @"VISIT_ID", nil];
    whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:entryid], empId,parameter, nil];
    
    NSArray *selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,empId , parameter]];

    NSString *enterStoreTime=nil;
    for (int i=0; i<[selectedDataArr count]; i++) {
        WSInoutStoreObject*temp=[selectedDataArr objectAtIndex:i];
        enterStoreTime=temp.intime;
    }
    
    NSArray *setNames=[NSArray arrayWithObjects:@"outtime", nil];
    NSArray *setValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:enterStoreTime], nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
    
}
- (NSString *)getStoreLocalImageWithStore:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType{
    
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]]) {
        entryid = store.Id;
    }else{
        entryid = @"";
    }
    
    NSArray *selectedDataArr = nil;
    switch (pType) {
        case EParameterType_ParentFC:
        {
            if (!parameter) {
                return nil;
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"modulefc"] ArgumentsValue:@[[NSString stringNotNilWithValue:entryid],[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        case EParameterType_VisitId:
        {
            if (!parameter) {
                return nil;
            }
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id",@"VISIT_ID"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID] , parameter]];
        }
            break;
        default:
        {
            
            selectedDataArr = [self queryWithNames:@[@"store_id",@"emp_id"] ArgumentsValue:@[entryid,[WSAppData getObjectbyKey:APPDATA_EMPID]]];
        }
            break;
    }
    
    WSInoutStoreObject *tmpInoutStoreObject = [selectedDataArr firstObject];
    NSArray *local_Images = [tmpInoutStoreObject.local_image componentsSeparatedByString:@","];
    // MSTD-3636 与安卓逻辑保持一致，本地取第一张照片
    return [local_Images firstObject];

}

//查询拜访过的门店的storeId数组
- (NSArray *)queryVisitedStoreIdArray
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"emp_id", @"biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], [WSAppData getObjectbyKey:APPDATA_BIZDATE], nil];
    
    NSArray*selectedDataArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    
    if (selectedDataArr && [selectedDataArr count] > 0) {
       NSMutableArray*  storeIdArray = [NSMutableArray array];
        
        for (WSInoutStoreObject* object in selectedDataArr) {
            NSString *storeId = object.store_id;
            if (storeId && [storeId length] > 0) {
                [storeIdArray addObject:storeId];
            }
        }
        return storeIdArray;
    }
    
    return nil;
}

 



#pragma mark - 清除旧数据方法
- (void)cleanOldData {
    
    LogTrace();
    
    NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray *whereNames = [NSArray arrayWithObjects:@"not biz_date", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:currenTime], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
    
    [self clearForceLeaveStore];
}

#pragma mark - 清除强制离店方法
- (void)clearForceLeaveStore {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *cacheDic = [userDefaults objectForKey:@"winForceLeaveDic"];

    NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSDictionary *currentTimeDic = [cacheDic objectForKey:currenTime];
    if (!currentTimeDic) {
        currentTimeDic = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [newDic setObject:currentTimeDic forKey:currenTime];
    
    [userDefaults setObject:newDic forKey:@"winForceLeaveDic"];
    [userDefaults synchronize];
}

#pragma mark - 强制更新离店方法
- (void)forceUpdateLeaveStoreWithStore:(WSStoreBean *)store andOtherParam:(NSString *)parameter andParamType:(EParameterType)pType {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *storeId = store.Id;
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select *from wch_inoutStore where emp_id = '%@' and store_id = '%@' and outtime = 'null'", empId, storeId];
    NSArray *array = [sqliteUtil queryDicDatasBySql:sql argumentsValues:nil];
    NSDictionary *inoutStoreObject = [array firstObject];
    NSString *enterStoreTime = [inoutStoreObject objectForKey:@"INTIME"];
    
    sql = [NSString stringWithFormat:@"update wch_inoutStore set outtime='%@' where store_id='%@' and emp_id='%@' and outtime = 'null'", enterStoreTime, storeId, empId];
    [[WSFMDatebase getInstance] executeUpdateWithSql:sql];
}

#pragma mark - 记录强制离店方法
- (void)setForceLeaveStoreWithStore:(WSStoreBean *)store {
    
    if (store.Id.length > 0) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *cacheDic = [userDefaults objectForKey:@"winForceLeaveDic"];

        NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSDictionary *currentTimeDic = [cacheDic objectForKey:currenTime];
        if (!currentTimeDic) {
            currentTimeDic = [NSDictionary dictionary];
        }
        NSMutableDictionary *currentTimeDicNew = [NSMutableDictionary dictionaryWithDictionary:currentTimeDic];
        [currentTimeDicNew setObject:store.Id forKey:store.Id];
        
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:cacheDic];
        [newDic setObject:currentTimeDicNew forKey:currenTime];

        [userDefaults setObject:newDic forKey:@"winForceLeaveDic"];
        [userDefaults synchronize];
    }
}

#pragma mark - 获取强制离店方法
- (BOOL)isForceLeaveStoreWithStore:(WSStoreBean *)store {
    
    if (store.Id.length > 0) {
        
        NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *cacheDic = [userDefaults objectForKey:@"winForceLeaveDic"];
        NSDictionary *currentTimeDic = [cacheDic objectForKey:currenTime];
        NSString *storeId = [currentTimeDic objectForKey:store.Id];
        return (storeId.length > 0 ? YES : NO);
    }
    return NO;
}

#pragma mark - 清除全部强制离店数据方法
- (void)clearAllForceLeaveStore {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"winForceLeaveDic"];
    [userDefaults synchronize];
}
#pragma mark----查询节点列表
- (NSString*)queryFunCodeListWithCurrentFunCode:(NSString*)currentFunCode{
    NSMutableString * funCode = [[NSMutableString alloc]init];
    NSString * sql = [NSString stringWithFormat:@"select fc from base_funcs where parentId = (select parentId from base_funcs   where fc = '%@' )",currentFunCode];
    NSMutableArray *funCodeList = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        NSString * fc = [rs objectForColumnName:@"fc"];
        [funCodeList addObject:fc];
    }
    for (NSString * funcsBean in funCodeList) {
        [funCode appendString:[NSString stringWithFormat:@"'%@',",funcsBean]];
    }
    NSString * allFuncode = [NSString stringWithFormat:@"%@",funCode];
    if (allFuncode.length>2) {
        allFuncode = [allFuncode substringToIndex:allFuncode.length-1];
    }
    return allFuncode;
    
}


@end
