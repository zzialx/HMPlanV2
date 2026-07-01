//
//  WSBaseStoreOtherDataTable.m
//  WinSFA
//
//  Created by heju on 15/12/8.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

/**
存储登陆的时候 第一次请求下发的数据.
 */

#import "WSBaseStoreOtherDataTable.h"
#import "NSDate+Category.h"

#define kValidateDays       7       // 删除7天前的数据

@implementation WSBaseStoreOtherDataTable



static WSBaseStoreOtherDataTable *baseStoreOtherData = nil;


+ (WSBaseStoreOtherDataTable *)sharedTable {
    @synchronized(self) {
        if (baseStoreOtherData == nil) {
            baseStoreOtherData = [[WSBaseStoreOtherDataTable alloc] init];
        }
    }
    return baseStoreOtherData;
}

- (void)cleanOldData
{
    LogTrace();
    
    // 删除 ReportForm 保存的下载数据
    // SFA-15692  根据业务日期 删除计划外请求的标识
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];

     NSString *sql = [NSString stringWithFormat:@"DELETE FROM base_store_other_data WHERE (type = '%@' or type = '%@') and biz_date <> '%@'",WSRF_DOWNLOAD_SEARCH_OBJ_STR_FLAG,WSASVC_OUTPLANSTORE_REQUESTED_FLAG, currenTime];
     [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
}

- (void)insertItem1Value:(NSString *)value1 Item2value:(NSString *)value2; {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *biz_Data = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    NSArray *array = [self queryBaseStoreOtherDataObject:value1];
    if (array && [array count] > 0) {
        [self deleteWithNames:[NSArray arrayWithObjects:@"item1", nil] ArgumentsValue:[NSArray arrayWithObjects:value1, nil]];
    }
    [self insertWithArgumentsValue:[NSArray arrayWithObjects:empId,@"",WINSFA_SHARE_DATA_TYPE,value1,value2,@"",@"",@"",@"",@"",@"",@"",@"",biz_Data,@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",nil]];
    
}

- (NSArray *)queryBaseStoreOtherDataObject:(NSString *)item1Value {
    NSArray *names = [NSArray arrayWithObjects:@"type",@"biz_date",@"item1", nil];
    NSString *biz_Data = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray *values = [NSArray arrayWithObjects:WINSFA_SHARE_DATA_TYPE,[NSString stringNotNilWithValue:biz_Data], [NSString stringNotNilWithValue:item1Value],nil];
    NSArray *array = [self queryWithNames:names ArgumentsValue:values];
    return  array;
}

-(id)valueForKey:(NSString *)key type:(NSString *)type
{
    NSArray *rets = [self queryWithNames:@[@"type",@"item1"] ArgumentsValue:@[type,key]];
    
    if (rets.count)
    {
        return [rets[0] valueForKey:@"item2"];
    }
    
    return nil;
}
#pragma mark - 切换用户时，清除otherdata表中的城市门店数量
- (void)cleanOldDataAboutCityStoreListCount
{
    NSString *sql = [NSString stringWithFormat:@"delete from base_store_other_data where type = '%@' ",WSCQVC_QUERY_STORE_CITY_LIST];
    
    [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
}
@end
