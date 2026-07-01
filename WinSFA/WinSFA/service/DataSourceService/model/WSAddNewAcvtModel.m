//
//  WSAddNewAcvtModel.m
//  WinSFA
//
//  Created by yang on 15/8/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAddNewAcvtModel.h"
#import "WSAcvtBean_qst.h"
#import "WSDataSourceManager.h"
#import "WSStoreAcvtDisBean.h"
#import "WSAcvtQstDisItem.h"

#import "WSBaseStoreAcvtDisTable.h"

@implementation WSAddNewAcvtModel



- (BOOL)isFromNewAddList
{
    return YES;
}

/*得到 在店下新增的店（也就是问卷问题的回显值）回显值*/
- (NSString *)getAcvtNewStoreServeRedisValueForStoreByQstId:(NSString *)qstId {
    __block NSString *qstValue = nil;
    [self.acvtNewStoreQstInfos enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        WSAcvtQstDisItem *item = (WSAcvtQstDisItem *)obj;
        if (item.acvtQstId && qstId && [item.acvtQstId isEqualToString:qstId]) {
            qstValue =  item.acvtanswer;
            *stop = YES;
        }
        
    }];
    return qstValue;
}

- (NSMutableArray *)getTAServerRedisValueForStoreByQstId:(NSString *)qstId {
    
   /*
    __block NSMutableArray *taRowValues = [NSMutableArray array];
    
    [self.currentStore.acvtDisArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        
        WSStoreAcvtDisBean *acvdisBean = (WSStoreAcvtDisBean *)obj;
        if (acvdisBean.gen_id && self.md5 && [acvdisBean.gen_id isEqualToString:self.md5]) {
            if ([acvdisBean.m_p count] >= 4) {
                NSString *storeId = [acvdisBean.m_p objectAtIndex:0];
                NSString *acvtId = [acvdisBean.m_p objectAtIndex:1];
                NSString *acvtQstId = [acvdisBean.m_p objectAtIndex:2];
                NSString *acvtQstValue = [acvdisBean.m_p objectAtIndex:3];
                if (acvtQstId && qstId && [acvtQstId isEqualToString:qstId]
                    && storeId && self.currentStore.Id && [storeId isEqualToString:self.currentStore.Id]
                    && acvtId && self.currentAcvtBean.acvtId && [acvtId isEqualToString:self.currentAcvtBean.acvtId]) {
                    [taRowValues  addObject: acvtQstValue];
                }
            }
        }
    }];
    return taRowValues;
     */
    NSMutableArray *names = [NSMutableArray arrayWithObjects:@"sid",@"acvtId",@"acvtQstId", nil];
    NSMutableArray *values = [NSMutableArray arrayWithObjects:self.currentStore.Id,self.currentAcvtBean.acvtId,qstId, nil];
    
    if (self.currentNewStore.Id && self.currentNewStore.Id.length > 0){
        [names addObject:@"newStoreId"];
        [values addObject:self.currentNewStore.Id];
    }

    
    NSArray *results =  [[WSBaseStoreAcvtDisTable sharedTable]  queryColValues:@"acvt_qst_answer" withName:names ArgumentsValue:values isDistinct:YES];
    
    return [NSMutableArray arrayWithArray:results];
}

- (NSArray *)getServerRedisData{
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    //门店数据已经改为从数据库读取，不能从内存中读取，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    /*
     //服务器数据
    NSMutableArray *newAddAcvtArray =[[NSMutableArray alloc]init];
    
    if ([self.currentAcvtBean isKindOfClass:[WSAcvtBean class]]) {
        WSAcvtBean *acvtBean = (WSAcvtBean *)self.currentAcvtBean;
        
        NSDictionary *dataDic = [self.currentStore calcAllAcvts:acvtBean.acvtId];
        
        for (NSString *genID  in [dataDic allKeys])
        {
            NSArray *qstDisArray = [dataDic objectForKey:genID];
            WSStoreAcvtDisBean *disBean = [qstDisArray firstObject];
            

            NSString *acvt_id = [disBean.m_p objectAtIndex:ACVTDIS_ACVTID];
            NSString *md5 = [NSString stringNotNilWithValue:disBean.gen_id];
            
            WSAcvtBean *acvtBean = self.currentAcvtBean;
            NSMutableString *name = [NSMutableString string];
            for (WSAcvtBean_qst *qst in acvtBean.qsts) {
                if ([qst.isAcvtName isEqualToString:@"1"]) {
                    for (WSStoreAcvtDisBean *disBean in qstDisArray) {
                        NSString *qstId = [disBean.m_p objectAtIndex:ACVTDIS_QSTID];
                        
                        if ([qst.acvtQstId isEqualToString:qstId]) {
                            NSString *qstValue = [disBean.m_p objectAtIndex:ACVTDIS_VALUE];
                            [name appendString:qstValue];
                        }
                    }
                }
            }
            
            
            NSString *func_code = [NSString stringNotNilWithValue:self.currentFuncs.fc];
            NSString *acvt_datas = nil;
            NSMutableDictionary *acvt_Dic = [NSMutableDictionary dictionary];
            for (WSAcvtBean_qst *tmpQst in acvtBean.qsts) {
                for (WSStoreAcvtDisBean *tmpDisBean in qstDisArray) {
                    NSString *qstId = [tmpDisBean.m_p objectAtIndex:ACVTDIS_QSTID];
                    NSString *qstValue = [tmpDisBean.m_p objectAtIndex:ACVTDIS_VALUE];
                    if ([tmpQst.acvtQstId isEqualToString:qstId] && ![tmpQst.acvtQstId isEqualToString:QST_TYPE_TA]) {
                        //TA类型的不加入  其当做问卷另存一条数据
                        NSString *qstkey = [NSString stringWithFormat:@"%@%@",tmpQst.qstType,tmpQst.acvtQstId ];
                        [acvt_Dic setObject:[NSString stringNotNilWithValue:qstValue] forKey:qstkey];
                    }
                }
            }
            acvt_datas = [NSString stringNotNilWithValue:[acvt_Dic JSONString]];
           
            NSString *acvt_newStoreId = [NSString stringNotNilWithValue:disBean.acvt_newStoreId];
            NSString *isLocal = @"0";
            
            WSAddStoreObject *addStoreObject = [[WSAddStoreObject alloc] init];
            addStoreObject.update_md5id = md5;
            addStoreObject.acvt_id = acvt_id;
            addStoreObject.func_code = func_code;
            addStoreObject.store_id = acvt_newStoreId;
            addStoreObject.is_local = isLocal;
            
            [newAddAcvtArray addObject:addStoreObject];
            
        }
    }

    return newAddAcvtArray;
     */
    return nil;

}

@end
