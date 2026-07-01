//
//  WSBaseSmsDataTable.m
//  WinSFA
//
//  Created by mac on 16/12/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseSmsDataTable.h"

@implementation WSBaseSmsDataTable
-(BOOL)insertDataWithContent:(NSString *)content receiver:(NSArray *)recivers result:(NSString * )result{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    BOOL re ;
    NSString * resultStr = [WSCurrentTime getDateTimeWithOutTime];
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableArray * sqls = [NSMutableArray arrayWithCapacity:recivers.count];
    for (NSString * reciver in recivers) {
        NSString * uuid =  [[NSUUID UUID] UUIDString];
        NSString * sql = [NSString stringWithFormat:@"insert into %@ ('emp_id','receiver_num','content','result_time','result_code','genId') VALUES ('%@','%@','%@','%@','%@','%@') ",dbTableName,empId,reciver,content,resultStr,result,uuid];
        
        [sqls addObject:sql];

    }
    re = [self insertWithSqls:sqls];

    return  re;

}
@end
