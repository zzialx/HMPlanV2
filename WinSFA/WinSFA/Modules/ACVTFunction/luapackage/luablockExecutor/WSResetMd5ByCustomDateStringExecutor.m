//
//  WSResetMd5ByCustomDateStringExecutor.m
//  WinSFA
//
//  Created by yang on 2017/7/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSResetMd5ByCustomDateStringExecutor.h"
#import "WSInterAction.h"

@implementation WSResetMd5ByCustomDateStringExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        WSInterAction  *interaction =[[WSInterAction alloc] init];
        [interaction setExecute_method:@selector(resetMd5ByCustomDateString:)];
        [interaction setExecute_method_param:firstObj];
        [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
        
        __strong typeof (sself.delegate) strongDelegate = sself.delegate;
        
        if ([sself.delegate respondsToSelector:@selector(executeInterAction:)]) {
            [sself.delegate executeInterAction:interaction];
        }
        
        strongDelegate = nil;
        
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
