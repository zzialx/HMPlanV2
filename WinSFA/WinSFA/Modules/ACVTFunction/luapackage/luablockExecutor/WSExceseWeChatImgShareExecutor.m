//
//  WSExceseWeChatImgShareExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSExceseWeChatImgShareExecutor.h"
#import "WSInterAction.h"

@implementation WSExceseWeChatImgShareExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        if ([firstObj isEqualToString:@"exceseWeChatImgShare"])
        {
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            va_end(argsList);
            
            NSString *secondObjString =[NSString stringWithFormat:@"%@",secondObj];
            NSArray *paramArray = [secondObjString componentsSeparatedByString:LUA_SEPARATOR];
            NSString *param1 = [paramArray firstObject];
            NSString *param2 = WeChatImgType;
            
            if (paramArray.count == 2) {
                param2 = [paramArray objectAtIndex:1];
            }
            NSDictionary *paramDict = @{@"shareStyle":param1,@"sendType":param2};

            WSInterAction  *interaction =[[WSInterAction alloc] init];
            if ([param1 isEqualToString:@"1"] ||[secondObjString isEqualToString:@"3"]) {
                // 微信分享
                [interaction setExecute_method:@selector(weChatImgShareButtonClick:)];
                interaction.execute_method_param = paramDict;
                
            }else if ([param1 isEqualToString:@"2"]) {
                // 只跳转到微信会话
                [interaction setExecute_method:@selector(weChatImgShareToWeChart:)];
            }
            
            if (interaction) {
                [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];
                
                if ([sself.delegate respondsToSelector:@selector(executeInterAction:)]) {
                    [sself.delegate executeInterAction:interaction];
                }
            }
            
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
