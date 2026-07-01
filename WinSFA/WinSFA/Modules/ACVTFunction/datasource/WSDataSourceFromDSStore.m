//
//  WSDataSourceForDSStore.m
//  WinSFA
//
//  Created by yang on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSStore.h"
#import "WSDataSourceManager.h"
#import "WSBaseStoreDBService.h"
#import "WSAcvtModel.h"

@implementation WSDataSourceFromDSStore

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] rangeOfString:STORE].location != NSNotFound) {
        
        if (self.parentSelectIdArray == nil) {
            
            NSString *empId = [[WSAppData sharedManager].datas objectForKey:APPDATA_EMPID];
            if ([self getTempEmpId].length >0) {
                empId = [self getTempEmpId];
            }
            
            NSMutableArray *queryStores = [NSMutableArray array];
            
            NSArray *search_objectArray  = [[buildInfo getDataSource] componentsSeparatedByString:@","];
            for (NSString *search_object in search_objectArray) {
                
                NSString *nodeName = [NSString stringNotNilWithValue:search_object];
                if ([nodeName isEqualToString:@"store"]) {
                    nodeName = @"stores";
                }
                
                //先pid传空，查出所有的，
                NSArray *storeArray = [[WSBaseStoreDBService shareInstance] queryStoreWithFilter:[buildInfo getFilterCondition] andNodeName:nodeName andEmpId:empId andPid:nil];
                
                
                NSString *pid = @"";
                WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
                if (![acvtModel.currentStore.Id isEqualToString:@"-1"] && (acvtModel.currentNewStore || acvtModel.isNewAddAcvt)) {
                    pid =  acvtModel.currentStore.Id;
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
                        storeArray = [[WSBaseStoreDBService shareInstance] queryStoreWithFilter:[buildInfo getFilterCondition] andNodeName:nodeName andEmpId:empId andPid:pid];
                    }
                }
                
                [queryStores addObjectsFromArray:storeArray];

            }
            self.dataSourceArray = [NSArray arrayWithArray:queryStores];
            
        }else {
            
            WSInPlanStoreBean *inPlanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
            WSOutPlanStoreBean* outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
            NSMutableArray *allStore = [NSMutableArray array];
            [allStore addObjectsFromArray:inPlanStoreArray.storesArray];
            [allStore addObjectsFromArray:outPlanStoreArray.storesArray];
            
            NSMutableArray *nameList = [[NSMutableArray alloc]init];

            for (WSStoreBean * storeBean in self.parentSelectIdArray) {
                
                for (WSStoreBean * tempStoreBean in allStore) {
                    // 科室名称
                    NSString * keshiName = nil;
                    // 医生名称
                    NSString * docName = nil;
                    if ([storeBean.Id isEqualToString:tempStoreBean.pid]) {
                        
                        keshiName = tempStoreBean.name;
                        // for 史克医院
                        for (WSStoreBean * tempStoreBeanDoc in allStore) {
                            if ( [tempStoreBean.Id isEqualToString:tempStoreBeanDoc.pid] ) {
                               
                                docName = tempStoreBeanDoc.name;
                                if (keshiName != nil && docName != nil) {
                                    //  i = i + 1;
                                    // 医院 + 科室 + 医生 名字
                                    WSStoreBean * namelistDatasouce = [[WSStoreBean alloc]init];
                                    
                                    NSString * allMessage = [NSString stringWithFormat:@"%@_%@_%@",storeBean.name,keshiName,docName];
                                    namelistDatasouce.name = allMessage;
                                    namelistDatasouce.Id = tempStoreBeanDoc.Id;
                                    [nameList addObject:namelistDatasouce];
                                }
                            }
                        }
                    }
                 
                }
            }
            
            self.dataSourceArray = nameList;    
        }
    }
    
    return self.dataSourceArray;
}

@end
