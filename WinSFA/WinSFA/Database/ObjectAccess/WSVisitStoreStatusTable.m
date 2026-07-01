//
//  WSVisitStoreStatusTable.m
//  WinSFA
//
//  Created by heju on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSVisitStoreStatusTable.h"
#import "BaseViewController.h"

static WSVisitStoreStatusTable *visitStoreStatusTable = nil;

@implementation WSVisitStoreStatusTable

+ (instancetype)shareInstance {
    static dispatch_once_t once_Token;
    if (visitStoreStatusTable == nil) {
        dispatch_once(&once_Token, ^{
            visitStoreStatusTable = [[WSVisitStoreStatusTable alloc] init];
        });
    }
    return visitStoreStatusTable;
}

//- (BOOL)updateStatusWithStoreId:(NSString *)storeId funcCode:(NSString *)funCode empId:(NSString *)empId{
//    
//    NSString *func_Code = [NSString stringNotNilWithValue:funCode];
//    NSString *store_id = [NSString stringNotNilWithValue:storeId];
//    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
//    NSArray *whereNames = @[@"func_code",@"store_id",@"emp_id",@"biz_date"];
//    NSArray *whereValues = @[func_Code,store_id,[NSString stringNotNilWithValue:empId],biz_date];
//    
//    NSArray *names = @[@"status"];
//    NSArray *values = @[@"1"];
//    return [self  updateWithNames:names values:values whereName:whereNames whereValue:whereValues];
//    
//}
//
//
//- (BOOL)insertStatusWithStore:(WSStoreBean *)currentStore funcCode:(NSString *)funcCode empId:(NSString *)empId{
//    
//    NSString *storeId = [NSString stringNotNilWithValue:currentStore.Id];
//    NSString *status = [NSString stringNotNilWithValue:@"2"];
//    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
//    NSString* func_code =[funcCode length] > 0 ? [NSString stringNotNilWithValue:funcCode]:@"null";
//    
//    NSString *isPlan = [NSString stringNotNilWithValue:[[NSNumber numberWithBool:currentStore.plan ] stringValue]];
//    NSArray *query_names = @[@"emp_id",@"store_id",@"biz_date"];
//    NSArray *query_values = @[[NSString stringNotNilWithValue: empId],storeId,biz_date];
//    NSArray *querys = [[WSVisitStoreStatusTable shareInstance] queryWithNames:query_names ArgumentsValue:query_values];
//    if ([querys count] > 0) {
//        NSString *updateSql = [NSString stringWithFormat:@"update visit_store_status set status = '%@' where  emp_id = '%@' and store_id = '%@' and biz_date = '%@' ",status,empId,storeId,biz_date];
//       return [[WSVisitStoreStatusTable shareInstance] executeUpdateWithSqls:@[updateSql]];
//    }
//    
//    NSArray *values = @[empId,storeId,status,biz_date,func_code,isPlan];
//    return [[WSVisitStoreStatusTable shareInstance] insertWithArgumentsValue:values];
//}

- (BOOL)updateStatusWithStore:(WSStoreBean *)currentStore funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status{
    NSString *storeId = [NSString stringNotNilWithValue:currentStore.Id];
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString* func_code = [NSString stringNotNilWithValue:funCode];
    
    NSString *isPlan = [NSString stringNotNilWithValue:[[NSNumber numberWithBool:currentStore.plan ] stringValue]];
//    NSArray *query_names = @[@"emp_id",@"store_id",@"biz_date",@"func_code"];
//    NSArray *query_values = @[[NSString stringNotNilWithValue: empId],storeId,biz_date,func_code];
    NSArray *query_names = @[@"emp_id",@"store_id",@"biz_date"];
    NSArray *query_values = @[[NSString stringNotNilWithValue: empId],storeId,biz_date];
//    //判断parentfc
//    if ([[WSInoutStoreTable sharedTable] queryFunCodeListWithCurrentFunCode:self.moduleFC].length>0) {
//        detectFc = [[WSInoutStoreTable sharedTable] queryFunCodeListWithCurrentFunCode:self.moduleFC];
//    }
    
    NSArray *querys = [[WSVisitStoreStatusTable shareInstance] queryWithNames:query_names ArgumentsValue:query_values];
    if ([querys count] > 0) {
//        NSString *updateSql = [NSString stringWithFormat:@"update visit_store_status set status = '%@' where  emp_id = '%@' and store_id = '%@' and biz_date = '%@' and func_code = '%@'",status,empId,storeId,biz_date, func_code];
        NSString * from_module = @"";
        NSString *updateSql = [NSString stringWithFormat:@"update visit_store_status set status = '%@', from_module = '%@' where  emp_id = '%@' and store_id = '%@' and biz_date = '%@'",status,from_module,empId,storeId,biz_date];
        LogInfo(@"visit_store_status update sql:%@",updateSql);
        return [[WSVisitStoreStatusTable shareInstance] executeUpdateWithSqls:@[updateSql]];
    }
    
    NSArray *values = @[empId,storeId,status,biz_date,func_code,isPlan,@""];
    return [[WSVisitStoreStatusTable shareInstance] insertWithArgumentsValue:values];
}
- (BOOL)updateStatusWithStore:(WSStoreBean *)currentStore funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status fromModule:(NSString*)fromModule{
    
    NSString *storeId = [NSString stringNotNilWithValue:currentStore.Id];
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString* func_code = [NSString stringNotNilWithValue:funCode];
    
    NSString *isPlan = [NSString stringNotNilWithValue:[[NSNumber numberWithBool:currentStore.plan ] stringValue]];

    NSArray *query_names = @[@"emp_id",@"store_id",@"biz_date"];
    NSArray *query_values = @[[NSString stringNotNilWithValue: empId],storeId,biz_date];
    
    NSArray *querys = [[WSVisitStoreStatusTable shareInstance] queryWithNames:query_names ArgumentsValue:query_values];
    if ([querys count] > 0) {
        NSString *updateSql = [NSString stringWithFormat:@"update visit_store_status set from_module = '%@' where  emp_id = '%@' and store_id = '%@' and biz_date = '%@'",fromModule,empId,storeId,biz_date];
        LogInfo(@"visit_store_status update fromModule sql:%@",updateSql);
        return [[WSVisitStoreStatusTable shareInstance] executeUpdateWithSqls:@[updateSql]];
    }
    NSArray *values = @[empId,storeId,[NSNull null],biz_date,func_code,isPlan,fromModule];

    return [[WSVisitStoreStatusTable shareInstance] insertWithArgumentsValue:values];
}

- (void)updateStatusWithStoreId:(NSString *)storeId funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status{
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString* func_code = [NSString stringNotNilWithValue:funCode];
    NSArray *query_names = @[@"emp_id",@"store_id",@"biz_date",@"func_code"];
    NSArray *query_values = @[[NSString stringNotNilWithValue: empId],storeId,biz_date,func_code];
    NSArray *querys = [[WSVisitStoreStatusTable shareInstance] queryWithNames:query_names ArgumentsValue:query_values];
    if ([querys count] > 0) {
        NSString *updateSql = [NSString stringWithFormat:@"update visit_store_status set status = '%@' where  emp_id = '%@' and store_id = '%@' and biz_date = '%@' and func_code = '%@'",status,empId,storeId,biz_date, func_code];
        LogInfo(@"updateStatusWithStoreId update  sql:%@",updateSql);
         [[WSVisitStoreStatusTable shareInstance] executeUpdateWithSqls:@[updateSql]];
        return;
    }
    
    NSArray *values = @[empId,storeId,status,biz_date,func_code];
    [[WSVisitStoreStatusTable shareInstance] insertWithArgumentsValue:values];
}

- (NSInteger)queryInPlanStoresVisitedCountWithFuncBean:(WSFuncsBean *)funcBean empId:(NSString *)empId biz_date:(NSString *)bizDate {
    NSString *status = [NSString stringWithFormat:@"(status = '%@' or status = '%@')",  VisitStoreDone, VisitStoreWorking];
    NSString * sqlString = [NSString stringWithFormat:@"select count(_id) from visit_store_status where emp_id = '%@' and %@ and  biz_date = '%@' and func_code = '%@'",
                            empId, status, [WSAppData getObjectbyKey:APPDATA_BIZDATE], funcBean.fc];
    WSSqliteUtil *object = [[WSSqliteUtil alloc] init];
    return [object queryCountWithSql:sqlString];
}

-(NSString *)queryStatusWithStoreId:(NSString *)storeId{
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *emp_id = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString * sqlString = [NSString stringWithFormat:@"select * from visit_store_status where store_id = '%@' and biz_date = '%@' and emp_id = '%@'",storeId,biz_date,emp_id];
    WSVisitStoreStatusObject * object = (WSVisitStoreStatusObject *)[[[WSSqliteUtil alloc] init] queryAndReturnSingleInfoBySql:sqlString andClassName:[WSVisitStoreStatusObject className]];
    return object.status;
}
#pragma mark - # 查询门店的拜访状态
+ (WSVisitStoreStatusObject *)queryVisitStoreStatusWithStoreId:(NSString *)storeId{
    
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
//    NSString *emp_id = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString * sqlString = [NSString stringWithFormat:@"select * from visit_store_status where store_id = '%@' and biz_date = '%@' ",storeId,biz_date];
    WSVisitStoreStatusObject * object = (WSVisitStoreStatusObject *)[[[WSSqliteUtil alloc] init] queryAndReturnSingleInfoBySql:sqlString andClassName:[WSVisitStoreStatusObject className]];
    return object;
}

- (void)cleanOldData
{
    LogTrace();
    
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray *whereNames=[NSArray arrayWithObjects:@"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:currenTime], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}


@end
