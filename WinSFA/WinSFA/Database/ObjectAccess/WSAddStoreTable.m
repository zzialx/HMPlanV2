//
//  WSAddStoreTable.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSAddStoreTable.h"
#import "WSAddStoreQstTable.h"

@implementation WSAddStoreTable

//static WSAddStoreTable *addStoreTable=nil;
//+(WSAddStoreTable*)sharedTable{
//    
//    if (addStoreTable==nil) {
//        
//        addStoreTable= [[WSAddStoreTable alloc]init];
//    }
//    return  addStoreTable;
//}
//
////清空所有的列
//- (void)cleanOldData
//{
//    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray *whereNames=[NSArray arrayWithObjects:@"upload_flag",@"not biz_date", nil];
//    NSArray *whereValues=[NSArray arrayWithObjects:@"1",[NSString stringNotNilWithValue:currenTime] ,nil];
//    
//    NSArray *uploadAddStoreArray=[self  queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    for(WSAddStoreObject* addStoredObject in uploadAddStoreArray){
//        NSArray *whereNames=[NSArray arrayWithObjects:@"ans_id", nil];
//        NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:addStoredObject.update_md5id] ,nil];
//        [[WSAddStoreQstTable sharedTable] deleteWithNames:whereNames ArgumentsValue:whereValues];
//    }
//    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
//}
//
//- (void)cleanOhterEmpData
//{
//    LogTrace();
//    NSArray *whereNames=[NSArray arrayWithObjects:@"upload_flag",@"not emp_id", nil];
//    NSArray *whereValues=[NSArray arrayWithObjects:@"1",[NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]] ,nil];
//    
//    NSArray *uploadAddStoreArray = [self queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    for(WSAddStoreObject* addStoredObject in uploadAddStoreArray){
//        NSArray *whereNames=[NSArray arrayWithObjects:@"ans_id", nil];
//        NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:addStoredObject.update_md5id] ,nil];
//        [[WSAddStoreQstTable sharedTable] deleteWithNames:whereNames ArgumentsValue:whereValues];
//    }
//    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
//}
//
//- (void)cleanWithNewData
//{
//    LogTrace();
////    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
//    NSArray *whereNames=[NSArray arrayWithObjects:@"upload_flag",nil];
//    NSArray *whereValues=[NSArray arrayWithObjects:@"1",nil];
//    
//    NSArray *uploadAddStoreArray = [self  queryWithNames:whereNames ArgumentsValue:whereValues];
//    
//    for(WSAddStoreObject* addStoredObject in uploadAddStoreArray){
//        NSArray *whereNames=[NSArray arrayWithObjects:@"ans_id",@"acvt_id", nil];
//        NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:addStoredObject.update_md5id], [NSString stringNotNilWithValue:addStoredObject.acvt_id],nil];
//        [[WSAddStoreQstTable sharedTable] deleteWithNames:whereNames ArgumentsValue:whereValues];
//    }
//    
//    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
//    
//}
//
//
//- (NSArray*)queryStoreByFc:(NSString *)fc
//{
////    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
////    return  [self queryWithNames:@[@"UPLOAD_FLAG",@"EMP_ID",@"FUNC_CODE"] ArgumentsValue:@[@"1", empId ,[NSString stringNotNilWithValue:fc]]];
////--todo
//    NSString* curtime = [NSString stringNotNilWithValue:[WSCurrentTime getDateString]];
//    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
//    return  [self queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID",@"FUNC_CODE"] ArgumentsValue:@[curtime,@"1", empId ,[NSString stringNotNilWithValue:fc]]];
//}
//
////  add by jimmy lee, I just wondering how these programmer were irresponsebility
//- (NSArray*)queryStoreByFc:(NSString *)fc andStoreId:(NSString *)storeId{
//    
////    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
////    
////    return  [self queryWithNames:@[@"UPLOAD_FLAG",@"EMP_ID",@"FUNC_CODE",@"STORE_ID"] ArgumentsValue:@[@"1", empId ,[NSString stringNotNilWithValue:fc],[NSString stringNotNilWithValue:storeId]]];
////--todo
//    NSString* curtime = [NSString stringNotNilWithValue:[WSCurrentTime getDateString]];
//    
//    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
//    
//     return  [self queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID",@"FUNC_CODE",@"STORE_ID"] ArgumentsValue:@[curtime,@"1", empId ,[NSString stringNotNilWithValue:fc],[NSString stringNotNilWithValue:storeId]]];
//}
//
//- (NSArray*)queryStoreByStoreId:(NSString *)storeId{
//    
////    NSString *empId = [WSAppData getObjectbyKey: APPDATA_EMPID];
////    
////    return  [self queryWithNames:@[@"UPLOAD_FLAG",@"EMP_ID",@"STORE_ID"] ArgumentsValue:@[@"1", empId ,storeId]];
////--todo
//    NSString* curtime = [WSCurrentTime getDateString];
//    
//    NSString *empId = [WSAppData getObjectbyKey: APPDATA_EMPID];
//    
//    return  [self queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID",@"STORE_ID"] ArgumentsValue:@[curtime,@"1", empId ,storeId]];
//}
//
//
//- (NSArray *)queryImmediatelyVistStore
//{
//    NSString* curtime = [WSCurrentTime getDateString];
//    NSString *empId = [WSAppData getObjectbyKey: APPDATA_EMPID];
//    return  [self queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID",@"ADD_TYPE"] ArgumentsValue:@[[NSString stringNotNilWithValue:curtime],@"1", [NSString stringNotNilWithValue:empId] , @"5"]];
//}
//
//
//- (BOOL)isNewStore:(NSString *)storeId {
//    NSArray *whereNames = [NSArray arrayWithObjects:@"store_id", nil];
//    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:storeId], nil];
//    NSInteger count = [[self queryWithNames:whereNames ArgumentsValue:whereValues] count];
//    if (count > 0) {
//        return YES;
//    }
//    return NO;
//}
//
//- (NSArray *)queryDataByStoreId:(NSString *)storeId acvtId:(NSString *)acvtId {
//    
//    NSString* curtime = [NSString stringNotNilWithValue:[WSCurrentTime getDateString]];
//    
//    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
//    
//    return  [self queryWithNames:@[@"BIZ_DATE",@"EMP_ID",@"acvt_id",@"STORE_ID"] ArgumentsValue:@[curtime, empId ,[NSString stringNotNilWithValue:acvtId],[NSString stringNotNilWithValue:storeId]]];
//    
//}
//
//- (WSAddStoreObject *)queryAddStoreObjByMd5:(NSString *)md5 {
//    
//    NSString* curtime = [NSString stringNotNilWithValue:[WSCurrentTime getDateString]];
//    
//    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
//    
//    return  [[self queryWithNames:@[@"BIZ_DATE",@"EMP_ID",@"update_md5id"] ArgumentsValue:@[curtime, empId ,[NSString stringNotNilWithValue:md5]]] firstObject];
//}

@end
