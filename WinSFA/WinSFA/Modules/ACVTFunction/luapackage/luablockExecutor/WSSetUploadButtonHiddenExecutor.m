//
//  WSSetUploadButtonHiddenExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSetUploadButtonHiddenExecutor.h"
#import "WSLuaDefine.h"

@implementation WSSetUploadButtonHiddenExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        
        if ([firstObjectString isEqualToString:[NSString stringWithUTF8String:LUA_SET_UPLOAD_BUTTON_HIDDEN]]) {
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            va_end(argsList);
            NSString *secondObjectString = [NSString stringWithFormat:@"%@",secondObj];

            BOOL isHidden = YES;
            if ([secondObjectString isEqualToString:@"0"] || [secondObjectString isEqualToString:@"false"]) {
                isHidden = NO;
            }
            
            LogInfo(@"WSSetUploadButtonHiddenExecutor,%@,%@", firstObjectString, secondObjectString);
            
            [sself.delegate setUploadButtonHidden:isHidden];
            
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
