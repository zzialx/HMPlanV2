//
//  WSSLDataSourceFromDSStore.m
//  WinSFA
//
//  Created by winchannel on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSLDataSourceFromDSStore.h"

@implementation WSSLDataSourceFromDSStore
- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] isEqualToString:STORE]) {
        //数据源来自stores节点
        WSInPlanStoreBean *inPlanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
        WSOutPlanStoreBean* outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
        NSMutableArray *allStore = [NSMutableArray array];
        [allStore addObjectsFromArray:inPlanStoreArray.storesArray];
        [allStore addObjectsFromArray:outPlanStoreArray.storesArray];
        
        
        NSMutableArray *storeArray = [[NSMutableArray alloc]init];
        
        for (NSObject<I_W_Cell> *storeBean in allStore) {
            [storeBean setIsExpland:NO];
            [storeBean setOptioned:NO];
        }
        
        //根据跟节点的pid为空，可找到跟节点，继而找到对应下的子节点
        for (NSObject<I_W_Cell> *storeBean in allStore) {
            //寻找第一级节点
            if ([storeBean getPid] == nil) {
                [storeBean setLevel_code:@"3"];
                
                [storeArray addObject:storeBean];
                
                NSMutableArray *sonBeanArray = [[NSMutableArray alloc]init];
                
                for (NSObject<I_W_Cell> *storeBean1 in allStore) {
                    
                    //寻找第二级节点
                    if ([[storeBean1 getPid] isEqualToString:[storeBean getId]]) {
                        
                        [storeBean1 setLevel_code:@"4"];
                        
                        //父节点中是否包含了子节点
                        if (![[storeBean getSonBean] containsObject:storeBean1]) {
                            
                            [sonBeanArray addObject:storeBean1];
                            
                            NSMutableArray *sonBeanArray2 = [[NSMutableArray alloc]init];
                            
                            for (NSObject<I_W_Cell> *storeBean2 in allStore) {
                                //寻找第三级节点
                                if ([[storeBean2 getPid] isEqualToString:[storeBean1 getId]]) {
                                    [storeBean2 setLevel_code:@"5"];
                                    //父节点中是否包含了子节点
                                    if (![[storeBean1 getSonBean] containsObject:storeBean2]) {
                                        [sonBeanArray2 addObject:storeBean2];
                                    }
                                }
                            }
                            [storeBean1 setSonBean:sonBeanArray2] ;
                        }
                    }
                }
                if (![storeBean getSonBean]) {
                     [storeBean setSonBean:sonBeanArray] ;
                }
               
            }
            
        }

        self.dataSourceArray = storeArray ;
                
    }
    
    return self.dataSourceArray;
}

@end
