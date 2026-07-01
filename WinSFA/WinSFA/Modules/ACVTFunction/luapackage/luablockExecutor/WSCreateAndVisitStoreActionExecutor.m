//
//  WSCreateAndVisitStoreActionExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSCreateAndVisitStoreActionExecutor.h"


#import "WSInoutStoreTable.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WSInterAction.h"
#import "WSLuaScript.h"
@implementation WSCreateAndVisitStoreActionExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        if (firstObj) {

            
            
            if ([firstObj isEqualToString:@"createAndVisitStoreAction"]) {
                
                NSObject *params = nil;
//                if ([sself.currentTargetObject respondsToSelector:@selector(getOtherLuaExecuteParams)]) {
//                    params = [sself.currentTargetObject getOtherLuaExecuteParams];
//                }
                
                WSInterAction  *interaction =[[WSInterAction alloc] init];
                if ([[[WSLuaScript getInstance] getLuaFunctionName] isEqualToString:@"notVisitStoreAction"]) {
                    [interaction setExecute_method:@selector(executeUpload)];

                } else {
                    [interaction setExecute_method:@selector(beginToVisitStore:)];
                    
                    va_list argslist;
                    va_start(argslist, firstObj);
                    id secondObj = va_arg(argslist, id);
                    va_end(argslist);
                    if (secondObj) {
                        params = [NSString stringWithFormat:@"%@",secondObj];;
                    }
                    
                    [interaction setExecute_method_param:params];
                }
                
                [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
                
                __strong typeof (sself.delegate) strongDelegate = sself.delegate;
                
                if ([sself.delegate respondsToSelector:@selector(executeInterAction:)]) {
                    [sself.delegate executeInterAction:interaction];
                }
                
                strongDelegate = nil;

            }
            
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
