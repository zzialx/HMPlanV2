//
//  WSDataSourceFromDSAcvt.m
//  WinSFA
//
//  Created by Stephanie on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSAcvt.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseOptionDataItem.h"
#import "WSBaseAcvtdisDBService.h"

@implementation WSDataSourceFromDSAcvt

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] isEqualToString:@"acvt"]) {
        
        NSArray *filterArray = [[buildInfo getFilterCondition] componentsSeparatedByString:@","];
        
        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
        
        if ([filterArray count] == 3) {
            //SFALHLH-237【联合利华】结束拜访--配置问题，ds-acvt，filter：acvtcode，qstcode，val
            //过滤acvtcode这个问卷在当前门店下的所有新增问卷，并且qstcode这个问题值为val的
            
            NSString *acvtCode = filterArray[0];
            NSString *qstCode = filterArray[1];
            NSString *qstValue = filterArray[2];
            
            WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
            WSAcvtBean *acvtBean = [service queryAcvtWithAcvtCode:acvtCode];
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:qstCode];
            
            //获取所有MD5
            WSBaseAcvtdisDBService *disService = [[WSBaseAcvtdisDBService alloc] init];
            NSArray *allMd5Array = [[disService queryAcvtMd5ArrayWithStoreID:model.currentStore.Id acvtID:acvtBean.acvtId] mutableCopy];
            NSMutableArray *md5Array = [NSMutableArray array];
            
            for (NSString *md5 in allMd5Array) {
                NSString *value = [disService queryQstValueWithStoreId:nil acvtId:acvtBean.acvtId acvtQstId:qstBean.acvtQstId genId:md5 isMatchGenId:YES bizDate:nil];
                if ([value isEqualToString:qstValue]) {
                    [md5Array addObject:md5];
                }
            }
            
            if ([md5Array count] > 0) {
                NSMutableArray *acvtNameQstArray = [NSMutableArray array];
                if ([acvtNameQstArray count] == 0) {
                    NSMutableArray *mainQstArray = [NSMutableArray array];
                    NSMutableArray *subQstArray = [NSMutableArray array];
                    
                    for (WSAcvtBean_qst *qst in acvtBean.qsts) {
                        if ([qst.isAcvtName isEqualToString:@"1"]) {
                            [mainQstArray addObject:qst];
                        }else if ([qst.isAcvtName isEqualToString:@"2"]) {
                            [subQstArray addObject:qst];
                        }
                    }
                    
                    [acvtNameQstArray addObjectsFromArray:mainQstArray];
                    [acvtNameQstArray addObjectsFromArray:subQstArray];
                }
                
                if ([acvtNameQstArray count] > 0) {
                    
                    NSMutableArray *dataSourceArray = [NSMutableArray arrayWithCapacity:md5Array.count];
                    
                    for (NSString *md5 in md5Array) {
                        NSMutableString *totalValue = [NSMutableString string];
                        for (WSAcvtBean_qst *qst in acvtNameQstArray) {
                            NSString *value = [disService queryPeopleQstValuePresentationByGenID:md5 acvtId:acvtBean.acvtId qstBean:qst];
                            if ([value length] > 0) {
                                [totalValue appendFormat:@"%@ ", value];
                            }
                        }
                        
                        WSBaseOptionDataItem *item = [[WSBaseOptionDataItem alloc] init];
                        item.itemID = md5;
                        item.itemName = totalValue;
                        
                        [dataSourceArray addObject:item];
                    }
                    
                    self.dataSourceArray = dataSourceArray;
                }
            }

        }else if ([filterArray count] == 2) {
            NSString *acvtCode = filterArray[0];
            NSString *qstCode = filterArray[1];
            
            WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
            WSAcvtBean *acvtBean = [service queryAcvtWithAcvtCode:acvtCode];
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:qstCode];
            
            WSBaseAcvtdisDBService *disService = [[WSBaseAcvtdisDBService alloc] init];
            
            NSArray *serviceObjArray = [disService queryStoreAcvtDisBeanArrayWithStoreID:model.currentStore.Id acvtQstID:qstBean.acvtQstId noteName:nil];
            NSArray *localObjArray = [disService queryLocalAcvtDisBeanArrayWithStoreID:model.currentStore.Id acvtQstID:qstBean.acvtQstId];
            
            NSMutableArray *resultArray = [NSMutableArray array];
            
            if ([localObjArray count] > 0) {
                for (WSVisitStoreAcvtDataObject *obj in localObjArray) {
                    if ([obj.acvt_qst_answer length] > 0) {
                        WSBaseOptionDataItem *item = [[WSBaseOptionDataItem alloc] init];
                        item.itemID = obj.gen_id;
                        item.itemName = obj.opt_value ?: obj.acvt_qst_answer;
                        
                        [resultArray addObject:item];
                    }
                }
            }else if ([serviceObjArray count] > 0) {
                for (WSBaseStoreAcvtDisObject *obj in localObjArray) {
                    if ([obj.acvt_qst_answer length] > 0) {
                        WSBaseOptionDataItem *item = [[WSBaseOptionDataItem alloc] init];
                        item.itemID = obj.gen_id ?: [NSString stringWithFormat:@"%@-%@-%@",obj.sid,obj.acvtid,obj.acvtqstid];
                        item.itemName = obj.opt_value ?: obj.acvt_qst_answer;
                        
                        [resultArray addObject:item];
                    }
                }
            }
            
            self.dataSourceArray = resultArray;
        }
    }
    
    return self.dataSourceArray;
}

@end
