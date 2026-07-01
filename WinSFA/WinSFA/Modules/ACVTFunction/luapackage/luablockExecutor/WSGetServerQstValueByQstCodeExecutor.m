//
//  WSGetServerQstValueByQstCodeExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/16.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSGetServerQstValueByQstCodeExecutor.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WSAppData.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"

@implementation WSGetServerQstValueByQstCodeExecutor

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj, ...) {
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        LogInfo(@"WSGetServerQstValueByQstCodeExecutor getLuaScriptWithParamsExpandBlock 1 firstObj=%@ secondObj=%@", firstObj, secondObj);
        if (firstObj && secondObj) {
            
            WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
            WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithQstCod:firstObj];
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:firstObj];
            LogInfo(@"WSGetServerQstValueByQstCodeExecutor getLuaScriptWithParamsExpandBlock 2 acvtBean.acvtId=%@ qstBean.acvtQstId=%@", acvtBean.acvtId, qstBean.acvtQstId);
            
            if ([qstBean.acvtQstId length] > 0) {

                NSString *storeID = nil;
                if ([secondObj isKindOfClass:[NSString class]]) {
                    
                    NSString *secondString = [secondObj uppercaseString];
                    if ([secondString isEqualToString:@"Y"]) {
                        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
                        storeID = model.currentStore.Id;
                    }
                    else if ([secondString isEqualToString:@"N"]) {
                        storeID = nil;
                    }
                    else if ([secondString length] > 0){
                        storeID = secondObj;
                    }
                }
                
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                NSString *value = [service queryQstServerValueWithStoreId:storeID acvtId:acvtBean.acvtId acvtQstId:qstBean.acvtQstId genId:nil];
                LogInfo(@"WSGetServerQstValueByQstCodeExecutor getLuaScriptWithParamsExpandBlock 3 storeID=%@ value=%@", storeID, value);
                
                if ([value length] > 0) {
                    return value;
                }
            }
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end

