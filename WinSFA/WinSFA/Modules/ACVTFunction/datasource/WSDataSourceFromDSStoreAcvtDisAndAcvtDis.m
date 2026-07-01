//
//  WSDataSourceFromDSStoreAcvtDisAndAcvtDis.m
//  WinSFA
//
//  Created by Stephanie on 16/9/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSStoreAcvtDisAndAcvtDis.h"
#import "WSStoreAcvtDisBean.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WSEnvrionment.h"
#import "WSBaseAcvtdisDBService.h"

@implementation WSDataSourceFromDSStoreAcvtDisAndAcvtDis

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] isEqualToString:@"storeacvtdis,acvtdis"]) {
        self.dataSourceArray = [self getDataSourceByFilter:[buildInfo getFilterCondition]];
    }
    
    return self.dataSourceArray;
}

- (NSArray *)getDataSourceByFilter:(NSString *)filter
{
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    
    return [self getDataSourceByFilter:filter storeID:model.currentStore.Id];
}

- (NSArray *)getDataSourceByFilter:(NSString *)filter storeID:(NSString *)storeID
{
    
    if ([WSEnvrionment getStoreDataFromDb]) {
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        
        NSArray *storeAcvtDisArray = [service queryStoreAcvtDisBeanArrayWithStoreID:storeID acvtQstID:filter noteName:nil];
        
        NSArray *allAcvtDisArray = [service queryStoreAcvtDisBeanArrayWithStoreID:nil acvtQstID:filter noteName:nil];
        
        NSArray *storeMd5Array = [storeAcvtDisArray valueForKeyPath:@"@distinctUnionOfObjects.gen_id"];
        
        NSMutableArray *allArray = [NSMutableArray arrayWithArray:storeAcvtDisArray];
        
        if ([storeMd5Array count] > 0) {
            for (WSBaseStoreAcvtDisObject *disObj in allAcvtDisArray) {
                if ([disObj.gen_id length] > 0 && ![storeMd5Array containsObject:disObj.gen_id]) {
                    [allArray addObject:disObj];
                }
            }
        }else {
            [allArray addObjectsFromArray:allAcvtDisArray];
        }
        
        
        self.dataSourceArray = allArray;
        
    }
    
    return self.dataSourceArray;
}

@end
