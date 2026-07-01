//
//  WSGetQstDataByQstNameAndGenidExecutor.m
//  WinSFA
//
//  Created by Stephanie on 16/9/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetQstDataByQstCodeAndGenidExecutor.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtQstDisItem.h"

@implementation WSGetQstDataByQstCodeAndGenidExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        if (firstObj && secondObj) {
            
            WSAcvtBean_qst *qstBean;
            WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
            WSBaseAcvtdisDBService *disService = [[WSBaseAcvtdisDBService alloc] init];
            
            if ([secondObj length] > 0) {
                NSString *acvtID;
                
                // 跟 android 逻辑保持一致
                NSArray *objArray = [disService queryLocalAcvtQstDatasByGenId:secondObj];
                WSAcvtQstDisItem *item = [objArray firstObject];
                if (item) {
                    acvtID = item.acvtId;
                }
                
                if (!acvtID) {
                    return nil;
                }
                
                WSAcvtBean *acvtBean = [acvtService queryAcvtWithAcvtID:acvtID];
                qstBean = [acvtBean getQstBeanByQstCod:firstObj];
            } else {
                qstBean = [acvtService queryQstWithAcvtQstCode:firstObj];
            }
            
            NSString *value = [disService queryQstValueWithStoreId:nil acvtId:nil acvtQstId:qstBean.acvtQstId genId:secondObj isMatchGenId:YES bizDate:nil];

            
            if ([value length] > 0) {
                return value;
            }
            
        }
        return nil;
    };
    
    return [paramExpanedBlock copy];
    
}

@end
