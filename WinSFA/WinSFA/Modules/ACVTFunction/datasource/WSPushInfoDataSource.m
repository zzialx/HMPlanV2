//
//  WSPushInfoDataSource.m
//  WinSFA
//
//  Created by xiajl on 15/4/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPushInfoDataSource.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"
#import "WSStoreInfoBeanArray.h"
#import "WSTableItemsArray.h"
#import "WSTableItem.h"
#import "WSFuncsBeanArray.h"

@implementation WSPushInfoDataSource

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    
    WSAcvtModel *baseModel = nil;
    
    if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]]) {
        
        baseModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        WSTableItem *tableItem =nil;
        
        WSTableItemsArray *tbArray = [WSAppData getObjectbyKey:TB];
        NSArray *itemsArray = [tbArray getTableItemWithMc:[buildInfo getMenuCode]];
        
        if ([itemsArray count] > 0) {
            tableItem = [itemsArray objectAtIndex:0];
        }else {
            tableItem = [self getTableItemWithMc:[buildInfo getMenuCode]];
        }
        
        NSArray *paramsArray = tableItem.paramArray;

        NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:10];
        
        NSString *dsValue = tableItem.ds;
        if([dsValue isEqualToString:@"store_info"] || [dsValue isEqualToString:@"store_Info"]){
            dsValue=@"storeInfo";
        }
        id objectArray = [WSAppData getObjectbyKey:dsValue];
        if ([objectArray isKindOfClass:[WSStoreInfoBeanArray class]]) {
            
            WSStoreInfoBeanArray *storeInfoBeans = ( WSStoreInfoBeanArray *)objectArray;
            for (WSStoreInfoBean *storeInBean in storeInfoBeans.storeinfoArray) {
                if (storeInBean.typ
                    && storeInBean.storeId
                    && [storeInBean.empId isEqualToString:[[baseModel currentStore] empId]]
                    && [storeInBean.storeId isEqualToString:[[baseModel currentStore] Id]]
                    && [storeInBean.typ isEqualToString:tableItem.filter]) {
                    
                    NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:[paramsArray count]];
                    //按表格配置顺序 显示列
                    for (WSFuncsBean_Param *param in paramsArray) {
                        if ([param.col isEqualToString:STOREINFO_COL1]) {
                            
                            [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col1]];
                        }else if ([param.col isEqualToString:STOREINFO_COL2]){
                            
                            [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col2]];
                        }else if ([param.col isEqualToString:STOREINFO_COL3]){
                            
                            [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col3]];
                        }else if ([param.col isEqualToString:STOREINFO_COL4]){
                            
                            [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col4]];
                        }else if ([param.col isEqualToString:STOREINFO_COL5]){
                            
                            [columnArray addObject:[NSString stringNotNilWithValue:storeInBean.col5]];
                        }
                    }
                    if([columnArray count] > 0){
                        [rowArray addObject:columnArray];
                    }
                    
                }
            }
        }
        
        
        ////    测试数据
        //    NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:3];
        //    [columnArray addObject:[NSString stringNotNilWithValue:@"1111"]];
        //    [columnArray addObject:[NSString stringNotNilWithValue:@"2222"]];
        //    [columnArray addObject:[NSString stringNotNilWithValue:@"3333"]];
        //    [columnArray addObject:[NSString stringNotNilWithValue:@"4444"]];
        //    [columnArray addObject:[NSString stringNotNilWithValue:@"5555"]];
        //    
        //    for (int i =0 ; i < 100; i++) {
        //        [rowArray addObject:columnArray];
        //    }
        
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArray  addObject:rowArray];
        
        self.dataSourceArray = sectionArray;
    }
    

    
    return self.dataSourceArray;
}

- (NSArray *) getHeadDataSourceFor
{

    return nil;
}

- (WSTableItem *)getTableItemWithMc:(NSString *)mc
{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *funcsBean = [funcsBeanArray getHideFuncsBeanWithFC:mc];
    WSTableItem *tableItem = nil;
    if (funcsBean) {
        tableItem = [[WSTableItem alloc] initWithFuncsBean:funcsBean];
    }
    
    return tableItem;
}


@end
