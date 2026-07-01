//
//  WSDVDataSourceFromStoreDicts.m
//  WinSFA
//
//  Created by zzialx on 2025/5/14.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSDVDataSourceFromStoreDicts.h"
#import "WSBaseDictsDBService.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"


@implementation WSDVDataSourceFromStoreDicts

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([buildInfo getDataSource] && [[buildInfo getDataSource] isEqualToString:STORE_DICTS]) {
        self.dataSourceArray = [self getDVDataSourceByFilter:[buildInfo getFilterCondition] andBuildInfo:buildInfo];
    }
    return self.dataSourceArray;
}
- (NSArray *)getDVDataSourceByFilter:(NSString *)filter andBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    NSString *storeId = nil;
    if ([model isKindOfClass:[WSAcvtModel class]]) {
        WSAcvtModel *acvtModel = (WSAcvtModel *)model;
        storeId = acvtModel.currentStore.Id;
    }
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *filterArray = [service queryStoreDictsWithStoreId:storeId filter:filter];
    self.dataSourceArray = filterArray;
    return self.dataSourceArray;
}


@end
