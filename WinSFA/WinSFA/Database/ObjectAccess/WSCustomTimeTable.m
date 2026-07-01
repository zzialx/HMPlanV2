//
//  WSCustomTimeTable.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-8-4.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSCustomTimeTable.h"

/**
 *  MSTD-1109
 *  MEMO2字段已用，存放MD5值； MD5生成规则请见BaseViewController的createMD5With方法。
 *  ENTER_STORE_FC字段 已用 存放 module_fc
 */

@implementation WSCustomTimeTable

+ (WSCustomTimeTable*)sharedTable
{
    static WSCustomTimeTable *instance = nil;
    @synchronized(self){
        if (instance == nil) {
            instance = [[WSCustomTimeTable alloc] init];
        }
        return instance;
    }
}

- (void)cleanOldData
{
    LogTrace();
    
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray *whereNames=[NSArray arrayWithObjects:@"not BIZ_DATE", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:currenTime], nil];
    
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}
-(void)insertEnterCustomTimeWithStoreId:(NSString*)storeId
                                 withFC:(NSString*)fc
                         withCustomDate:(NSString*)dateStr
                            withVisitId:(NSString*)visitId {
    if (!storeId || !fc || !dateStr || !visitId) {
        return;
    }
    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:7];
    [valueArray addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    [valueArray addObject:storeId];
    [valueArray addObject:fc];
    [valueArray addObject:@"0"];
    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [valueArray addObject:[formatter stringFromDate:[NSDate date]]];
    
    [valueArray addObject:dateStr];
    [valueArray addObject:[WSCurrentTime getTimeString]];
    
    [valueArray addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    
    [valueArray addObject:visitId];
    [self insertWithArgumentsValue:valueArray];
    
}


- (void) insertEnterCustomTimeWithStoreId:(NSString*)storeId
                                   withFC:(NSString*)fc
                           withCustomDate:(NSString*)dateStr
                           withCustomTime:(NSString*)timeStr
                              withVisitId:(NSString*)visitId
{
    if (!storeId || !fc || !dateStr || !timeStr || !visitId) {
        return;
    }
    
    [self deleteWithNames:@[@"MEMO2",@"STORE_ID",@"ENTER_STORE_FC"] ArgumentsValue:@[visitId,storeId,fc]];
    
    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:7];
    [valueArray addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    [valueArray addObject:storeId];
    [valueArray addObject:fc];
    [valueArray addObject:@"0"];
    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [valueArray addObject:[formatter stringFromDate:[NSDate date]]];
    
    [valueArray addObject:dateStr];
    [valueArray addObject:timeStr];
    
    [valueArray addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    
    [valueArray addObject:visitId];
    [self insertWithArgumentsValue:valueArray];
}

- (void) insertEnterNormalTimeWithStoreId:(NSString*)storeId
                                   withFC:(NSString*)fc
                              withVisitId:(NSString*)visitId
{
    if (!storeId || !fc || !visitId) {
        return;
    }
    
    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:7];
    [valueArray addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    [valueArray addObject:storeId];
    [valueArray addObject:fc];
    [valueArray addObject:@"0"];
    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [valueArray addObject:[formatter stringFromDate:[NSDate date]]];
    
    [valueArray addObject:[WSCurrentTime getDateString]];
    [valueArray addObject:[WSCurrentTime getTimeString]];
    
    [valueArray addObject: [WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    [valueArray addObject: @"normal"];
    [valueArray addObject: visitId];
    
    NSMutableString *valueStr = nil;
    for (NSString *tmp in valueArray) {
        if (valueStr == nil) {
            valueStr = [[NSMutableString alloc] initWithFormat:@"'%@'", tmp];
        }else {
            [valueStr appendFormat:@", '%@'", tmp];
        }
    }
    
    NSString *insertSql= @"insert into wch_customTime ('EMP_ID', 'STORE_ID', 'ENTER_STORE_FC', 'UPLOAD_FLAG', 'ENTER_DISPOSE_TIME', 'CUSTOM_ENTER_DATE', 'CUSTOM_ENTER_TIME', 'BIZ_DATE', 'MEMO1','MEMO2')";
    NSString *logString = [NSString stringWithFormat:@"%@ values (%@)", insertSql, valueStr];
    
    [self insertWithSqls: [NSArray arrayWithObject:logString]];
}

- (BOOL) updateLeaveCustomTimeWithStoreId:(NSString*)storeId
                           withCustomTime:(NSString*)timeStr
                              withVisitId:(NSString*)visitId
{
    
    if (!visitId) {
        LogError(@"补录数据表，离线时间更新失败，memo2字段的值不能为空！visitId = %@",visitId);
        return NO;
    }
    
    NSArray* queryArray =[self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"UPLOAD_FLAG", @"CUSTOM_LEAVE_TIME",@"MEMO2",nil] ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId, @"0", [NSNull null] ,visitId, nil]];
    
    if (queryArray && [queryArray count] == 1) {
        NSArray *whereNames=[NSArray arrayWithObjects:@"EMP_ID",@"STORE_ID", @"UPLOAD_FLAG", @"MEMO2", nil];
        NSArray *whereValues=[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId, @"0", visitId, nil];
        
        NSArray *setNames=[NSArray arrayWithObjects:@"LEAVE_DISPOSE_TIME", @"CUSTOM_LEAVE_DATA", @"CUSTOM_LEAVE_TIME", nil];
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *curDateStr = [formatter stringFromDate:[NSDate date]];
        
        NSArray *setValues=[NSArray arrayWithObjects:curDateStr, [[queryArray objectAtIndex:0] custom_enter_date], timeStr, nil];
        
        return [self  updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
    }
    else if (queryArray && [queryArray count] > 1) {
        LogError(@"multi custom time store1：%@", queryArray);
        
        NSArray *whereNames=[NSArray arrayWithObjects:@"EMP_ID",@"STORE_ID",@"MEMO2", nil];
        NSArray *whereValues=[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId, visitId, nil];
        
        NSArray *setNames=[NSArray arrayWithObjects:@"LEAVE_DISPOSE_TIME", @"CUSTOM_LEAVE_DATA", @"CUSTOM_LEAVE_TIME", nil];
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *curDateStr = [formatter stringFromDate:[NSDate date]];
        
        NSArray *setValues=[NSArray arrayWithObjects:curDateStr, [[queryArray lastObject] custom_enter_date], timeStr, nil];
        
        return [self  updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
    }
    
    return NO;
}

- (BOOL) updateCustomTimeFinishedWithStoreId:(NSString*)storeId withVisitId:(NSString*)visitId
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"EMP_ID",@"STORE_ID", @"UPLOAD_FLAG", @"MEMO2", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId, @"0", visitId, nil];
    
    NSArray *setNames=[NSArray arrayWithObjects:@"UPLOAD_FLAG", nil];
    NSArray *setValues=[NSArray arrayWithObjects:@"1", nil];
    
    return [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues ];
}

- (BOOL) isCustomTimeWithStoreId:(NSString*)storeId withNeedNoLeaveStore:(BOOL) noLeaveStore withVisitId:(NSString*)visitId
{
    NSArray* queryArray=nil;
    if(noLeaveStore){
        queryArray =[self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"UPLOAD_FLAG", @"CUSTOM_LEAVE_TIME", @"MEMO1", nil]
                          ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId ==nil ? @"": storeId, @"0", [NSNull null], [NSNull null], nil]];
    }else{
        queryArray =[self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"UPLOAD_FLAG", @"MEMO1", nil]
                          ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId ==nil ? @"": storeId, @"0", [NSNull null], nil]];
    }

    if (queryArray && [queryArray count] == 1) {
        return YES;
    }
    else if (queryArray && [queryArray count] > 1) {
        LogError(@"multi custom time store2：%@", queryArray);
        return YES;
    }
    
    return NO;
}

- (NSString*) queueCustomEnterDateWithStoreId:(NSString*)storeId 
{
    if (!storeId) {
        return nil;
    }
    // MMSH-2094 添加 LEAVE_DISPOSE_TIME 为空的条件，过滤掉已经补录过且离店的数据
    NSArray* queryArray = [self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"LEAVE_DISPOSE_TIME", nil] ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId ,[NSNull null], nil]];
    if (queryArray) {
        WSCustomTimeObject* object = [queryArray lastObject];
        if (object && !object.memo1) {
            return object.custom_enter_date;
        }
    }
    
    return nil;
}

- (NSString*) queueCustomEnterDateWithStoreId:(NSString*)storeId withParentFc:(NSString *)module_fc
{
    if (!storeId) {
        return nil;
    }
    // MMSH-2104 添加 LEAVE_DISPOSE_TIME 为空的条件，过滤掉已经补录过且离店的数据
    NSArray* queryArray = [self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"ENTER_STORE_FC", @"LEAVE_DISPOSE_TIME", nil] ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId ,module_fc, [NSNull null], nil]];
    if (queryArray) {
        WSCustomTimeObject* object = [queryArray lastObject];
        if (object && !object.memo1) {
            return object.custom_enter_date;
        }
    }
    
    return nil;
}

- (NSString*) queueCustomEnterDateWithStoreId:(NSString*)storeId withVisitId:(NSString*)visitId
{
    if (!storeId) {
        return nil;
    }
    
    NSArray *nameArray = nil;
    NSArray *valueArray = nil;
    // MMSH-2094 添加 LEAVE_DISPOSE_TIME 为空的条件，过滤掉已经补录过且离店的数据
    if (visitId) {
        nameArray = [NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"MEMO2", @"LEAVE_DISPOSE_TIME", nil];
        valueArray = [NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId , visitId, [NSNull null], nil];
    }else {
        nameArray = [NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"LEAVE_DISPOSE_TIME",  nil];
        valueArray = [NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId, [NSNull null], nil];
    }
    
    
    NSArray* queryArray = [self queryWithNames:nameArray ArgumentsValue:valueArray];
    if (queryArray) {
        WSCustomTimeObject* object = [queryArray lastObject];
        if (object && !object.memo1) {
            return object.custom_enter_date;
        }
    }
    
    return nil;
}

- (NSArray*) queryCustomDateAndTimeWithStoreId:(NSString*)storeId withNeedNoLeaveStore:(BOOL) noLeaveStore withVisitId:(NSString*)visitId
{
    NSArray* queryArray=nil;
    if(noLeaveStore){
        queryArray =[self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"UPLOAD_FLAG", @"CUSTOM_LEAVE_TIME", @"MEMO1", @"MEMO2", nil]
                          ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId ==nil ? @"": storeId, @"0", [NSNull null], [NSNull null], visitId, nil]];
    }else{
        queryArray =[self queryWithNames:[NSArray arrayWithObjects:@"EMP_ID", @"STORE_ID", @"UPLOAD_FLAG", @"MEMO1", @"MEMO2", nil]
                          ArgumentsValue:[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID], storeId ==nil ? @"": storeId, @"0", [NSNull null], visitId, nil]];
    }

    if (queryArray && [queryArray count] == 1) {
        WSCustomTimeObject* object = [queryArray objectAtIndex:0];
        NSString *leaveDateStr = object.custom_leave_data;
        NSString *leaveTimeStr = object.custom_leave_time;
        
        if (leaveDateStr && leaveDateStr.length > 0 && leaveTimeStr && leaveTimeStr.length > 0) {
            return [NSArray arrayWithObjects:leaveDateStr, leaveTimeStr, nil];
        }
        
        return [NSArray arrayWithObjects:object.custom_enter_date, object.custom_enter_time, nil];
    }
    else if (queryArray && [queryArray count] > 1) {
        LogError(@"multi custom time store3：%@", queryArray);
        WSCustomTimeObject* object = [queryArray lastObject];
        NSString *leaveDateStr = object.custom_leave_data;
        NSString *leaveTimeStr = object.custom_leave_time;
        
        if (leaveDateStr && leaveDateStr.length > 0 && leaveTimeStr && leaveTimeStr.length > 0) {
            return [NSArray arrayWithObjects:leaveDateStr, leaveTimeStr, nil];
        }
        
        return [NSArray arrayWithObjects:object.custom_enter_date, object.custom_enter_time, nil];
    }
    return nil;
}


@end
