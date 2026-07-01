//
//  WSDataSourceFromDSAcvtdis.m
//  WinSFA
//
//  Created by yang on 16/10/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSAcvtdis.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WSEnvrionment.h"
#import "WSBaseAcvtdisDBService.h"

@implementation WSDataSourceFromDSAcvtdis

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
//    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    
    if ([[buildInfo getDataSource] isEqualToString:ACVTDIS]) {
        
        if ([WSEnvrionment getStoreDataFromDb]) {
            
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            
            // SFA-15469 优先使用后台实时数据，若没有则使用登陆下发的缓存数据
            self.dataSourceArray = [service queryStoreAcvtDisBeanArrayAcvtQstID:[buildInfo getFilterCondition] noteName:[buildInfo getDataSource] isRemoteSearch:YES];
            
            if (!(self.dataSourceArray && self.dataSourceArray.count > 0)) {
                self.dataSourceArray = [service queryStoreAcvtDisBeanArrayAcvtQstID:[buildInfo getFilterCondition] noteName:[buildInfo getDataSource] isRemoteSearch:NO];
            }
            
//            self.dataSourceArray = [service queryStoreAcvtDisBeanArrayWithStoreID:nil acvtQstID:[buildInfo getFilterCondition] noteName:[buildInfo getDataSource]];
        }
    }
    
    return self.dataSourceArray;
}

@end
