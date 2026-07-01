//  WSPeopleListDatasource.m
//  WinSFA
//
//  Created by zhangke on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPeopleListDatasource.h"
#import "I_W_DataSource.h"
#import "WSPeopleObject.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSBaseAcvtdisDBService.h"

@implementation WSPeopleListDatasource
@synthesize currentStore;


-(NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    /*
    NSArray* datasource= [[WSAddStoreTable sharedTable] queryWithNames:@[@"store_id",@"upload_flag"] ArgumentsValue:@[currentStore.Id,@"1"]];
    
    NSMutableArray* dataArray=[[NSMutableArray alloc] init];

    
    for (WSAddStoreObject* addStore in datasource) {
        
        NSArray* addStoreQstArray=  [[WSAddStoreQstTable sharedTable] queryWithNames:@[@"ans_id"] ArgumentsValue:@[addStore.update_md5id]];
        
        NSDictionary* dic=[NSDictionary dictionaryWithObject:addStoreQstArray forKey:addStore.update_md5id];
        
        [dataArray addObject:dic];

    }
     */
    
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    //先按照原逻辑修改，但是感觉此处逻辑不对，应该有个acvtType或者id的。不应该只根据store_id查询
    NSArray *dataSource = [service queryAcvtDatasWithStoreID:currentStore.Id acvtType:nil searchText:nil genIDs:nil isRead:NO isRemoteSearch:NO acvtSort:@"0"];

    self.dataSourceArray = dataSource;
    
    return dataSource;
}







@end
