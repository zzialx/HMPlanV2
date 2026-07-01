//
//  WSGetCurStoreInfoByParamExecutor.m
//  WinSFA
//
//  Created by heju on 2017/1/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSGetCurStoreInfoByParamExecutor.h"

#import "WSAcvtModel.h"

#import "WSDataSourceManager.h"

#import "WSWidget.h"

@implementation WSGetCurStoreInfoByParamExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        
        NSString *paramStr = [NSString stringWithFormat:@"%@" ,firstObj];
        
        if ([paramStr length] > 0 ) {
            
            LogInfo(@"WSGetCurStoreInfoByParamExecutor,paramStr:%@ ", paramStr);
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            if (!model.currentStore) {
                LogError(@"getCurStoreInfoByParam Error");
                return @"";
            }
            if ([paramStr isEqualToString:@"_id"]) {
                return [model.currentStore valueForKey:@"Id"];
            } else if ([paramStr isEqualToString:@"cod"]) {
                return [model.currentStore valueForKey:@"code"];
            } else if ([paramStr isEqualToString:@"dist_rule_id"]) {
                return [model.currentStore valueForKey:@"drId"];
            } else if ([model.currentStore valueForKey:paramStr]) {
                return [model.currentStore valueForKey:paramStr];
            }
            
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
