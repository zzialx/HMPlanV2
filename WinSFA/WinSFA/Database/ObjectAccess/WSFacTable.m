//
//  WSFacTable.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSFacTable.h"
#import "WSImagePathTable.h"


@implementation WSFacTable

static WSFacTable *facTable=nil; 
//+(WSFacTable*)sharedTable{
//    
//    if (facTable==nil) {
//        
//        facTable= [[WSFacTable alloc]init];
//    }
//    return  facTable;
//}
//
//
////清空所有的列
//- (void)cleanOldData
//{
//    LogTrace();
//    NSString *currentTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    
//    NSArray* array=[self queryWithNames:@[@"not biz_date"] ArgumentsValue:@[[NSString stringNotNilWithValue:currentTime]]];
//    for(WSFacObject* object in array){
//        [[WSFacQstTable sharedTable] deleteWithNames:@[@"ans_id"] ArgumentsValue:@[object.img_idx]];
//    }
//    
//    [self deleteWithNames:@[@"not biz_date"] ArgumentsValue:@[[NSString stringNotNilWithValue:currentTime]]];
//}
//
//
////插入
//- (BOOL)insertWithFacArray:(NSArray *)Values Qst:(NSArray *)qstValues
//{
//    NSArray *whereNames=[NSArray arrayWithObjects:@"img_idx",nil];
//    NSArray *whereValues=[NSArray arrayWithObjects:[Values objectAtIndex:8], nil];
//    
//    NSArray *fdtArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    if(fdtArray && fdtArray.count>0){
//        NSString *fdtImg_idx=[[fdtArray objectAtIndex:0] img_idx];
//        
//        NSArray *whereNam=[NSArray arrayWithObjects:@"ans_id", nil];
//        NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fdtImg_idx], nil];
//        [[WSFacQstTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
//    }
//    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
//    
//    
//    
//    NSMutableArray* sqlArray=[NSMutableArray array];
//    
//    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
//    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
//    
//    NSString *valueString = [NSString string];
//    for (NSString *value in Values) {
//        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
//    }
//    
//    valueString = [valueString substringToIndex:valueString.length - 1];
//    insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
//    insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
//    
//    [sqlArray addObject:insertSql];
//    
//    
//    for(id object  in qstValues){
//        if([object isKindOfClass:[NSArray class]]){
//            
//            NSString* dbTableName=[WSPlistHelper valueForKey:[WSFacQstTable className] withPlistName:kDataBaseMappingFileName];
//            NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
//            
//            NSString *valueString = [NSString string];
//            for (NSString *value in object) {
//                valueString = [valueString stringByAppendingFormat:@"'%@',", value];
//            }
//            
//            valueString = [valueString substringToIndex:valueString.length - 1];
//            insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
//            insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
//            
//            [sqlArray addObject:insertSql];
//            
//        }else{
//            [sqlArray addObject:[self insertqst:(NSDictionary*)object]];
//            
//        }
//    }
//    return [self insertWithSqls:sqlArray];
//    
// }
//
//- (NSString*)insertqst:(NSDictionary *)aDic {
//    
//    NSString *keyString = [NSString string];
//    NSString *valueString = [NSString string];
//    
//    NSArray *keys = [aDic allKeys];
//    
//    for (NSString *key in keys) {
//        NSString *value = [aDic objectForKey:key];
//        if (!value) {
//            value = @"null";
//        }
//        keyString = [keyString stringByAppendingFormat:@"%@,", key];
//        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
//    }
//    
//    keyString = [keyString substringToIndex:keyString.length - 1];
//    valueString = [valueString substringToIndex:valueString.length - 1];
//    NSString *sql = [NSString stringWithFormat:@"insert into wch_facQst (%@) values (%@);", keyString, valueString];
//    return sql;
//}
//-(BOOL)deleteAcvtInfo:(WSFuncsBean*)funcs NestedAcvtId:(NSString*)acvtid
//{
//   NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray* wherenames = [NSArray arrayWithObjects:@"store_id",@"func_code",@"acvt_id",@"biz_date",@"emp_id" ,nil];
//    NSArray* wherevalues = [NSArray arrayWithObjects:@"new",[NSString stringNotNilWithValue:funcs.fc],[NSString stringNotNilWithValue:acvtid],[NSString stringNotNilWithValue:currenTime], [WSAppData getObjectbyKey:APPDATA_EMPID] ,nil];
//    return [self deleteWithNames:wherenames ArgumentsValue:wherevalues];
//}
//
//-(BOOL)upadteAcvtInfo:(WSFuncsBean*)funcs andStoreId:(NSString *)storeId NestedAcvtId:(NSString*)acvtid{
//    
//    if (!acvtid || !storeId || !funcs) {
//        return NO;
//    }
//    
//    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray* setnames = [[NSArray alloc] initWithObjects:@"store_id", nil];
//    NSArray* setvalues = [[NSArray alloc] initWithObjects:[NSString stringNotNilWithValue:storeId],nil];
//    NSArray* wherenames = [NSArray arrayWithObjects:@"store_id",@"func_code",@"acvt_id",@"biz_date",@"emp_id" ,nil];
//    NSArray* wherevalues = [NSArray arrayWithObjects:@"new",[NSString stringNotNilWithValue:funcs.fc],[NSString stringNotNilWithValue:acvtid],[NSString stringNotNilWithValue:currenTime], [WSAppData getObjectbyKey:APPDATA_EMPID] ,nil];
//    return [self updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
//}
//-(BOOL)upadteAcvtInfo:(NSString *)md5 andStoreId:(NSString *)storeId{
//    
//    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray* setnames = [[NSArray alloc] initWithObjects:@"store_id", nil];
//    NSArray* setvalues = [[NSArray alloc] initWithObjects:[NSString stringNotNilWithValue:storeId],nil];
//    NSArray* wherenames = [NSArray arrayWithObjects:@"store_id",@"biz_date",@"emp_id" ,nil];
//    NSArray* wherevalues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:md5],[NSString stringNotNilWithValue:currenTime], [WSAppData getObjectbyKey:APPDATA_EMPID] ,nil];
//    return [self updateWithNames:setnames values:setvalues whereName:wherenames whereValue:wherevalues];
//}
////查询fac_qst表的信息
//-(NSArray*)queryAcvtInfo:(WSStoreBean*)store Funcs:(WSFuncsBean*)funcs NestedAcvtId:(NSString*)acvtid andParentGenId:(NSString *)pgenId{
//    
//    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
//    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
//    
//    NSString *storeId = (store.Id && [store.Id length] > 0) ? [NSString stringNotNilWithValue:store.Id] : @"new" ;
//    //store_id
//    [whereNames addObject:@"store_id"];
//    [whereValues addObject:storeId];
//    //func_code
//    [whereNames addObject:@"func_code"];
//    [whereValues addObject:[NSString stringNotNilWithValue:funcs.fc]];
//    //acvt_id
//    [whereNames addObject:@"acvt_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:acvtid]];
//    //biz_date
//    [whereNames addObject:@"biz_date"];
//    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
//    //emp_id
//    [whereNames addObject:@"emp_id"];
//    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    
//    //SR_ID
//    [whereNames addObject:@"SR_ID"];
//    if (store.storeAccessMode == WSStoreAccessModeSubEmp
//        && store.srid
//        && [store.srid length] > 0)
//    {
//        [whereValues addObject:[NSString stringNotNilWithValue:store.srid]];
//    }else{
//        [whereValues addObject:@"null"];
//    }
//    
//    
//    [whereNames addObject:@"p_gen_id"];
//    
//    [whereValues addObject:pgenId];
//    
//    NSArray *uploadInfoArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//
//    return uploadInfoArray;
//}
//
////查询fac_qst表的信息,特意为了兼容老版本应用程序而留下的
//-(NSArray*)queryAcvtInfo:(WSStoreBean*)store Funcs:(WSFuncsBean*)funcs NestedAcvtId:(NSString*)acvtid{
//    
//    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
//    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
//    
//    NSString *storeId = (store.Id && [store.Id length] > 0) ? [NSString stringNotNilWithValue:store.Id] : @"new" ;
//    //store_id
//    [whereNames addObject:@"store_id"];
//    [whereValues addObject:storeId];
//    //func_code
//    [whereNames addObject:@"func_code"];
//    [whereValues addObject:[NSString stringNotNilWithValue:funcs.fc]];
//    //acvt_id
//    [whereNames addObject:@"acvt_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:acvtid]];
//    //biz_date
//    [whereNames addObject:@"biz_date"];
//    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
//    //emp_id
//    [whereNames addObject:@"emp_id"];
//    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    
//    //SR_ID
//    [whereNames addObject:@"SR_ID"];
//    if (store.storeAccessMode == WSStoreAccessModeSubEmp
//        && store.srid
//        && [store.srid length] > 0)
//    {
//        [whereValues addObject:[NSString stringNotNilWithValue:store.srid]];
//    }else{
//        [whereValues addObject:@"null"];
//    }
//    
//
//    
//    NSArray *uploadInfoArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    
//    return uploadInfoArray;
//}
//
//
//-(NSArray*)queryAcvtInfoWithMD5:(NSString *)md5 Funcs:(WSFuncsBean*)funcs  AcvtId:(NSString*)acvtid{
//    
//    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray *whereNames=[NSArray arrayWithObjects:@"store_id",@"func_code",@"acvt_id",@"biz_date",@"emp_id",@"IMG_IDX" ,nil];
//    NSArray *whereValues=[NSArray arrayWithObjects:@"new",[NSString stringNotNilWithValue:funcs.fc],[NSString stringNotNilWithValue:acvtid],[NSString stringNotNilWithValue:currenTime], [WSAppData getObjectbyKey:APPDATA_EMPID],[NSString stringNotNilWithValue:md5], nil];
//
//    NSArray *uploadInfoArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    if(uploadInfoArray.count>0){
//        WSFacObject *tem=[uploadInfoArray lastObject];
//        NSString *facImg_idx=tem.img_idx;
//        
//        NSArray *whereN=[NSArray arrayWithObjects:@"ans_id", nil];
//        NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:facImg_idx], nil];
//        return [[WSFacQstTable sharedTable] queryWithNames:whereN ArgumentsValue:whereV];
//    }
//    
//    return uploadInfoArray;
//}
//-(NSArray*)queryAcvtInfo:(id)store acvtNewStore:(WSStoreBean *)acvtNewStore Funcs:(WSFuncsBean *)funcs AcvtId:(NSString *)acvtid andMD5:(NSString *)md5
//{
//    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
//    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
//    NSString *storeId  = nil;
//    if ([store isKindOfClass:[WSStoreBean class]]) {
//        WSStoreBean *storeBean = (WSStoreBean *)store;
//        storeId = storeBean.Id;
//        if (storeBean.iStoreIdentify != nil)
//        {
//            NSString *storeIDJoint = [NSString stringWithFormat:@"%@_%@", storeBean.Id, storeBean.iStoreIdentify];
//            storeId = storeIDJoint;
//            
//        }
//        if ([acvtNewStore.Id isKindOfClass:[NSString class]] && [acvtNewStore.Id length] > 0) {
//            storeId = acvtNewStore.Id;
//        }
//
//        
//    } else if ([store isKindOfClass:[WSSubempstoreBean class]]) {
//        storeId = [(WSSubempstoreBean*)store Id];
//    }else if ([store isKindOfClass:[WSHosBean class ]]) {
//        storeId = [(WSHosBean *)store Id];
//    }
//    if (storeId == nil) {
//        storeId = @"new";
//    }
//    
//    
//    /*
//    NSString *storeId = (store.Id && [store.Id length] > 0) ? [NSString stringNotNilWithValue:store.Id] : @"new" ;
//     */
//    //store_id
//    [whereNames addObject:@"store_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:storeId]];
//    //func_code
//    [whereNames addObject:@"func_code"];
//    [whereValues addObject:[NSString stringNotNilWithValue:funcs.fc]];
//    //acvt_id
//    [whereNames addObject:@"acvt_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:acvtid]];
//    //biz_date
//    [whereNames addObject:@"biz_date"];
//    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
//    //emp_id
//    [whereNames addObject:@"emp_id"];
//    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    
//    //IMG_IDX
//    if (md5 && [md5 length] > 0) {
//        [whereNames addObject:@"IMG_IDX"];
//        [whereValues addObject:[NSString stringNotNilWithValue:md5]];
//    }
//    
//    //SR_ID
//    
//    [whereNames addObject:@"SR_ID"];
//    if ([store isKindOfClass:[WSStoreBean class]]) {
//        WSStoreBean *tmpStore = (WSStoreBean *)store;
//        if (tmpStore.storeAccessMode == WSStoreAccessModeSubEmp
//            && tmpStore.srid
//            && [tmpStore.srid length] > 0)
//        {
//            [whereValues addObject:[NSString stringNotNilWithValue:tmpStore.srid]];
//        }else{
//            [whereValues addObject:@"null"];
//        }
//    } else if ([store isKindOfClass:[WSSubempstoreBean class]]){
//        [whereValues addObject:@"null"];
//    }else if ([store isKindOfClass:[WSHosBean class]]) {
//       [whereValues addObject:@"null"];
//    }
//    
//    NSArray *uploadInfoArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    if(uploadInfoArray.count>0){
//        WSFacObject *tem=[uploadInfoArray lastObject];
//        NSString *facImg_idx=tem.img_idx;
//        
//        NSArray *whereN=[NSArray arrayWithObjects:@"ans_id", nil];
//        NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:facImg_idx], nil];
//        return [[WSFacQstTable sharedTable] queryWithNames:whereN ArgumentsValue:whereV];
//    }
//    return nil;
//
//}
////查询fac_qst表的信息(m_fac_qst信息)
//-(NSArray*)queryAcvtInfo:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore Funcs:(WSFuncsBean*)funcs AcvtId:(NSString*)acvtid{
//    
//    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
//    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
//    
//    NSString *storeId  = nil;
//    if ([store isKindOfClass:[WSStoreBean class]]) {
//        WSStoreBean *storeBean = (WSStoreBean *)store;
//        storeId = storeBean.Id;
//        if (storeBean.iStoreIdentify != nil)
//        {
//            NSString *storeIDJoint = [NSString stringWithFormat:@"%@_%@", storeBean.Id, storeBean.iStoreIdentify];
//            storeId = storeIDJoint;
//        }
//        if ([acvtNewStore.Id isKindOfClass:[NSString class]] && [acvtNewStore.Id length] > 0) {
//            storeId = acvtNewStore.Id;
//        }
//    } else if ([store isKindOfClass:[WSSubempstoreBean class]]) {
//        storeId = [(WSSubempstoreBean*)store Id];
//    }
//    
//    if (storeId == nil) {
//        storeId = @"new";
//    }
//    
//    //store_id
//    [whereNames addObject:@"store_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:storeId]];
//    //func_code
//    [whereNames addObject:@"func_code"];
//    [whereValues addObject:[NSString stringNotNilWithValue:funcs.fc]];
//    //acvt_id
//    [whereNames addObject:@"acvt_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:acvtid]];
//    //biz_date
//    [whereNames addObject:@"biz_date"];
//    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
//    //emp_id
//    [whereNames addObject:@"emp_id"];
//    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    
//    //SR_ID
//    
//
//    if ([store isKindOfClass:[WSStoreBean class]]) {
//        [whereNames addObject:@"SR_ID"];
//        if (store.storeAccessMode == WSStoreAccessModeSubEmp
//            && store.srid
//            && [store.srid length] > 0)
//        {
//            [whereValues addObject:[NSString stringNotNilWithValue:store.srid]];
//        }else{
//            [whereValues addObject:@"null"];
//        }
//    }
//    NSArray *uploadInfoArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    if(uploadInfoArray.count>0){
//        WSFacObject *tem=[uploadInfoArray lastObject];
//        NSString *facImg_idx=tem.img_idx;
//        
//        NSArray *whereN=[NSArray arrayWithObjects:@"ans_id", nil];
//        NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:facImg_idx], nil];
//        return [[WSFacQstTable sharedTable] queryWithNames:whereN ArgumentsValue:whereV];
//    }
//    return nil;
//}
//
////查询照片信息
//-(NSArray*)queryAcvtImagePathInfo:(WSStoreBean*)store Funcs:(WSFuncsBean*)funcs AcvtId:(NSString*)acvtid{
//    
//    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
//    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
//    
//    NSString *storeId = (store.Id && [store.Id length] > 0) ? [NSString stringNotNilWithValue:store.Id] : @"new" ;
//    //store_id
//    [whereNames addObject:@"store_id"];
//    [whereValues addObject:storeId];
//    //func_code
//    [whereNames addObject:@"func_code"];
//    [whereValues addObject:[NSString stringNotNilWithValue:funcs.fc]];
//    //acvt_id
//    [whereNames addObject:@"acvt_id"];
//    [whereValues addObject:[NSString stringNotNilWithValue:acvtid]];
//    //biz_date
//    [whereNames addObject:@"biz_date"];
//    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
//    //emp_id
//    [whereNames addObject:@"emp_id"];
//    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    
//    //SR_ID
//    [whereNames addObject:@"SR_ID"];
//    if (store.storeAccessMode == WSStoreAccessModeSubEmp
//        && store.srid
//        && [store.srid length] > 0)
//    {
//        [whereValues addObject:[NSString stringNotNilWithValue:store.srid]];
//    }else{
//        [whereValues addObject:@"null"];
//    }
//    
//    NSArray *uploadInfoArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    if(uploadInfoArray.count>0){
//        WSFacObject *temp=[uploadInfoArray lastObject];
//        NSString *img_idx = temp.img_idx;
//        
//        NSArray *dicArray = [[WSImagePathTable sharedTable] queryWithImageIDX:img_idx];
//        return dicArray;
//    }
//    return nil;
//}


@end
