//
//  WSDataSourceForDSDicts.m
//  WinSFA
//
//  Created by yang on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSDicts.h"
#import "WSBaseDictsDBService.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"

@implementation WSDataSourceFromDSDicts

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([buildInfo getDataSource] && [[buildInfo getDataSource] isEqualToString:DICTS]) {
        self.dataSourceArray = [self getDataSourceByFilter:[buildInfo getFilterCondition]];
        
    }
    return self.dataSourceArray;
}

- (NSArray *)getDataSourceByFilter:(NSString *)filter
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *filterArray = [service queryDictsWithParentId:self.parentSelectedItemID filter:filter];
    self.dataSourceArray = filterArray;
    return self.dataSourceArray;
}
- (NSArray *)getDataSourceByFilter:(NSString *)filter andBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray *filterArray = [service queryDictsWithParentId:self.parentSelectedItemID filter:filter memo:[buildInfo getAcvtMemo]];
    self.dataSourceArray = filterArray;
    return self.dataSourceArray;
}


@end
