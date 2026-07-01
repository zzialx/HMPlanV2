//
//  WSFuncTipDBService.m
//  WinSFA
//
//  Created by yang on 2017/8/30.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSFuncTipDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreOtherDataTable.h"

@implementation WSFuncTipDBService

#pragma mark - 重写replaceToTableWithDicts:FromNode:hasNewData:方法(保存到自己的表中)
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    if([nodeName hasPrefix:FUNC_TIP_DIS]){
        [service deleteWithType:nodeName];
        NSString *key = @"tip";
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dicts.count];
        for (NSDictionary *dic in dicts)
        {
            NSString *item1 = dic[@"fc"];
            NSString *item2 = dic[key];
            NSString *empId = dic[@"empId"];
            NSString * storeId = @"";
            if([dic.allKeys containsObject:@"sid"]){
                storeId = dic[@"sid"];
            }
            
            if ([item1 length] > 0)
                [dataArray addObject:@{
                    @"type" : nodeName,
                    @"item1" : item1,
                    @"item2" : (item2 ?: @"0"),
                    @"emp_id" : empId,
                    @"store_id": storeId
                }];
        }
        
        return [service replaceToTableWithDicts:dataArray FromNode:nodeName hasNewData:YES];
        
    }else{
        [service deleteWithType:FUNC_TIP];
        NSString *key = @"tip";
        if (![nodeName isEqualToString:FUNC_TIP]) {
            key = @"count";
        }
        
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dicts.count];
        for (NSDictionary *dic in dicts)
        {
            NSString *item1 = dic[@"fc"];
            NSString *item2 = dic[key];
            NSString *empId = dic[@"empId"];
            
            if ([item1 length] > 0)
                [dataArray addObject:@{@"type" : FUNC_TIP, @"item1" : item1, @"item2" : (item2 ?: @"0"), @"emp_id" : empId}];
        }
        
        return [service replaceToTableWithDicts:dataArray FromNode:FUNC_TIP hasNewData:YES];
        
    }
    
    
}
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    [service deleteWithType:nodeName storeId:storeID];
    NSString *key = @"tip";
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dicts.count];
    for (NSDictionary *dic in dicts)
    {
        NSString *item1 = dic[@"fc"];
        NSString *item2 = dic[key];
        NSString *empId = dic[@"empId"];
        NSString * storeId = dic[@"sid"];
        
        if ([item1 length] > 0)
            [dataArray addObject:@{
                                @"type" : nodeName,
                                @"item1" : item1,
                                @"item2" : (item2 ?: @"0"),
                                @"emp_id" : empId,
                                @"store_id": storeId
            }];
    }
    
    return [service replaceToTableWithDicts:dataArray FromNode:nodeName hasNewData:YES];
}
#pragma mark - 通过funcCode和empId查询提示标示方法
+ (NSString *)queryTipWithFuncCode:(NSString *)funcCode andEmpId:(NSString *)empId
{
    if (funcCode.length <= 0 || empId.length <= 0)
        return nil;
    
    NSArray *tipArray = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type", @"item1", @"emp_id"] ArgumentsValue:@[FUNC_TIP, funcCode, empId]];
    WSBaseStoreOtherDataObject *tipObject = [tipArray firstObject];
    return tipObject.item2;
}
#pragma mark - 更新菜单未读数量
+ (void)updateTipWithFuncCode:(NSString *)funcCode andStoreId:(NSString *)storeId  count:(NSString*)count{
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];

    if (funcCode.length <= 0 || empId.length <= 0){
        LogError(@"菜单为空或者人员 id 为空");
        return;
    }
    NSArray * names = @[@"item2"];
    NSArray * values = @[count];
    
    NSArray * whereNames = @[@"emp_id",@"store_id",@"item1"];
    NSArray * whereValues = @[empId,storeId,funcCode];
    
    BOOL isUpdateSuccess = [[WSBaseStoreOtherDataTable sharedTable] updateWithNames:names values:values whereName:whereNames whereValue:whereValues];
    if (!isUpdateSuccess) {
        LogError(@"updateTipWithFuncCode is failure");
    }
    
}

@end
