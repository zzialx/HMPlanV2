//
//  WSSaveCustomEnterLeaveTimeExecutor.m
//  WinSFA
//
//  Created by yang on 2017/7/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSaveCustomEnterLeaveTimeExecutor.h"
#import "WSInterAction.h"
#import "WSCustomTimeTable.h"
#import "WSAcvtModel.h"
#import "WSAcvtViewController.h"
#import "WSDataSourceManager.h"

@implementation WSSaveCustomEnterLeaveTimeExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        if ([firstObj isKindOfClass:[NSString class]]) {
            
            NSArray *array = [(NSString *)firstObj componentsSeparatedByString:@","];
            if ([array count] == 2) {
                NSString *date = array[0];
                NSString *time = array[1];
                
                if ([date length] > 0 && [time length] > 0) {
                    
                    
                    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
                    
                    NSString* storeList_parentFC = nil;
                    if (model.ownAcvtViewController.moduleFC) {
                        storeList_parentFC = model.ownAcvtViewController.moduleFC;
                    }
                    
                    va_list argsList;
                    va_start(argsList, firstObj);
                    id secondObj = va_arg(argsList, id);
                    va_end(argsList);
                    NSString *type = secondObj;
                    
                    //0：进店，1：离店
                    if ([type isEqualToString:@"0"]) {
                        //补填数据处理
                        [[WSCustomTimeTable sharedTable] insertEnterCustomTimeWithStoreId:model.currentStore.Id
                                                                                   withFC:storeList_parentFC
                                                                           withCustomDate:date
                                                                           withCustomTime:time
                                                                              withVisitId:model.md5];
                        
                        if ([[time componentsSeparatedByString:@":"] count] == 2) {//上传时，时间格式加上秒
                            time = [NSString stringWithFormat:@"%@:00",time];
                        }
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                        [dic setObject:date forKey:kRepairEnterStoreDateKey];
                        [dic setObject:time forKey:kRepairEnterStoreTimeKey];
                        model.customEnterStoreTimeDic = dic;
                        // needReplaceSyncDate 补录功能为1时打开。
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"needReplaceSyncDate"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }else {
                        
                        //更新离店补录时间
                        [[WSCustomTimeTable sharedTable] updateLeaveCustomTimeWithStoreId:model.currentStore.Id
                                                                           withCustomTime:time
                                                                              withVisitId:model.md5];
                        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"needReplaceSyncDate"];
                        [[NSUserDefaults standardUserDefaults] synchronize];


                    }
                    
                    
                }
            }
            
            
            
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
