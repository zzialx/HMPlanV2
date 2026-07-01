//
//  WSDataSourceFromDSStoreAcvtDis.m
//  WinSFA
//
//  Created by yang on 15/8/18.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSStoreAcvtDis.h"
#import "WSStoreAcvtDisBean.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WSEnvrionment.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtBean_qst.h"

@implementation WSDataSourceFromDSStoreAcvtDis

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    
    if ([[buildInfo getDataSource] isEqualToString:STOREACVTDIS]) {
        
        if ([WSEnvrionment getStoreDataFromDb]) {
            
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            
            WSBaseAcvtDBService *serviceAcvt = [[WSBaseAcvtDBService alloc] init];
            
            WSAcvtBean_qst *qstBean = [serviceAcvt queryQstWithQstCod:[buildInfo getFilterCondition]];
            
            self.dataSourceArray = [service queryStoreAcvtDisBeanArrayWithStoreID:model.currentStore.Id acvtQstID:qstBean.acvtQstId noteName:nil];

            
        }else {
            NSMutableArray *filterArray = [[NSMutableArray alloc] init];
            
            if (model.currentStore.acvtDisArray && [buildInfo getFilterCondition]) {
                [model.currentStore.acvtDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSStoreAcvtDisBean *storeAcvtDisBean = (WSStoreAcvtDisBean *)obj;
                    if ([storeAcvtDisBean.m_p count] > ACVTDIS_QSTID) {
                        if ([[storeAcvtDisBean.m_p objectAtIndex:ACVTDIS_QSTID]  isEqualToString:[buildInfo getFilterCondition]]) {
                            [filterArray addObject:storeAcvtDisBean];
                        }
                    }
                    
                }];
                self.dataSourceArray = filterArray;
            }
        }
    }
    
    return self.dataSourceArray;
}

@end
