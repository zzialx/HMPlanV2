//
//  WSGetQstServerDataByQstCodeAndGenid.m
//  WinSFA
//
//  Created by yang on 16/9/19.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetQstServerDataByQstCodeAndGenidExecutor.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtQstDisItem.h"

@implementation WSGetQstServerDataByQstCodeAndGenidExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        if (firstObj && secondObj) {
            
            NSString *acvtID;
            
            WSBaseAcvtdisDBService *disService = [[WSBaseAcvtdisDBService alloc] init];
            
            NSArray *objArray = [disService queryAcvtQstDatasByGenId:secondObj];
            WSAcvtQstDisItem *item = [objArray firstObject];
            if (item) {
                acvtID = item.acvtId;
            }
            
            if (!acvtID) {
                return nil;
            }
            
            WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
            WSAcvtBean *acvtBean = [acvtService queryAcvtWithAcvtID:acvtID];
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:firstObj];
            
            NSString *value = [disService queryQstServerValueWithStoreId:nil acvtId:nil acvtQstId:qstBean.acvtQstId genId:secondObj];
            
            LogInfo(@"%@,%@,%@,result:%@", [self class], firstObj, secondObj,value);
            
            if ([value length] > 0) {
                return value;
            }
            
        }
        return nil;
    };
    
    return [paramExpanedBlock copy];
    
}

@end
