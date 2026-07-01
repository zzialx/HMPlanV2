//
//  WSRelationRequireLuaBlock.m
//  WinSFA
//
//  Created by winchannel on 15/4/9.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRelationRequireLuaExecutor.h"

#import "WSLuaScriptEnter.h"



@implementation WSRelationRequireLuaExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
    __strong __typeof(wself) sself = wself;
        
        va_list argsList;
        if (firstObj) {
            
            NSString  *selectedContent = (NSString *)[[sself currentTargetObject] getValuePresentationForCurrentObject];
            va_start(argsList, firstObj);
            id secondObj;
            secondObj = va_arg(argsList, id);
            
            NSString *qstNames = nil;

            LogInfo(@"firstObj:%@,currentSelectedValue:%@,secondObj:%@", firstObj, selectedContent,secondObj);
            
            NSString *selectedItems =@"";
            if ([firstObj isKindOfClass:[NSString class]]) {
                qstNames = [NSString stringWithFormat:@"%@",firstObj];
            }
            if([secondObj isKindOfClass:[NSString class]]){
                selectedItems = [NSString stringWithFormat:@"%@",secondObj];
            }
            va_end(argsList);
            
            LogInfo(@"qstNames = %@" ,qstNames);
            LogInfo(@"selectedItems = %@" ,selectedItems);
            
            NSObject<I_Lua_Target_Operator>  * tempoperator =  [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstNames];

     
            if (qstNames && selectedItems) {
                
                NSArray *itemsArray = [selectedItems componentsSeparatedByString:@","];
                
                if (((!selectedContent || [selectedContent isEqualToString:@""]) && [itemsArray containsObject:@""])
                    || [itemsArray containsObject:selectedContent]) {
                    
                  [tempoperator reSetNeedValidate:YES];
                    
                    
                }else{
                    
                  
                    
                  [tempoperator reSetNeedValidate:NO];
                    
                }
            }
        }
        return @"1";
    };
    
    return [paramExpanedBlock copy];

}

- (NSString *)doExecute:(WSLuaScriptEnter *)executerEnter{
    
    return [executerEnter runOnCheck];
    
}
@end
