//
//  WSDataSourceFromPromotion.m
//  WinSFA
//
//  Created by winchannel on 2017/10/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromPromotion.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"

@implementation WSDataSourceFromPromotion

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    if ([[buildInfo getDataSource] isEqualToString:@"promotion:pinfo"]) {
        WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        WSAcvtBean *acvtBean = acvtModel.currentAcvtBean;
        WSBaseStoreOtherDataDBService *dbService = [[WSBaseStoreOtherDataDBService alloc] init];
        self.dataSourceArray =   [dbService queryWithType:[buildInfo getDataSource] withItem16:acvtBean.acvtId];
    }
    
    return self.dataSourceArray;
    
}

@end
