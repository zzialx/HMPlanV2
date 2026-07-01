//
//  WSDVDataSourceFromDSStore.m
//  WinSFA
//
//  Created by yang on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDVDataSourceFromDSStore.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseStoreTable.h"
#import "WSAcvtModel.h"

@implementation WSDVDataSourceFromDSStore

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] rangeOfString:STORE].location != NSNotFound) {
//        SFA-17470 董宏 与安卓逻辑缺失
        NSString *empId = nil;
        if([buildInfo getFilterCondition].length>0)
        {
         empId = [[WSAppData sharedManager].datas objectForKey:APPDATA_EMPID];
        }
        if ([self getTempEmpId].length >0) {
            empId = [self getTempEmpId];
        }
        
        NSString *nodeName = [buildInfo getDataSource];
        if ([nodeName isEqualToString:@"store"]) {
            nodeName = @"stores";
        }
        
        //先pid传空，查出所有的，
        NSArray *storeArray = [[WSBaseStoreDBService shareInstance] queryStoreWithFilter:[buildInfo getFilterCondition] andNodeName:nodeName andEmpId:empId andPid:nil];
        
        
        NSString *pid = @"";
        WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        if (acvtModel.currentNewStore || acvtModel.isNewAddAcvt) {
            pid = acvtModel.currentStore.Id;
        }
        
        //店内新增时无法区分是否按照pid查询，史克医院有pid,其他项目也有店内新增问卷，但是门店并没有层级关系
        //所以看一下数据是否包含pid, 有pid说明有层级关系，则按照pid查询，否则不查pid
        
        if ([pid length] > 0) {
            BOOL hasPid = NO;
            for (WSStoreBean *storeBean in storeArray) {
                if ([storeBean.pid length] > 0) {
                    hasPid = YES;
                    break;
                }
            }
            
            if (hasPid) {
                storeArray = [[WSBaseStoreDBService shareInstance] queryStoreWithFilter:[buildInfo getFilterCondition] andNodeName:[buildInfo getDataSource] andEmpId:empId andPid:pid];
            }
        }
        
        self.dataSourceArray = storeArray;
    }
    return self.dataSourceArray;
}

@end
