//
//  WSGenerateURLExecutor.m
//  WinSFA
//
//  Created by xiajl on 15/5/11.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSGenerateURLExecutor.h"
#import "WinSFA.h"
#import "WSLuaScriptEnter.h"
#import "WSSelectInformationPanel.h"

@interface WSGenerateURLExecutor()

@end;

@implementation WSGenerateURLExecutor
-(id)init {
    self = [super init];
    
    if (self) {
        
        
        return self;
    }
    return nil;
}

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        NSLog(@"%@", firstObj);
        if (firstObj) {
            NSString *qstNameString = [NSString stringWithFormat:@"%@" ,firstObj];
            WSSelectInformationPanel  * panel =  [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstNameString];
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            NSString *paramsString = [NSString stringWithFormat:@"%@",secondObj];
            va_end(argsList);
            if (paramsString) {
                NSArray *paramsArray = [paramsString componentsSeparatedByString:@","];
                NSMutableString *mstring = [NSMutableString stringWithCapacity:1];
                for (NSString *param in paramsArray) {
                    [mstring appendFormat:@"&%@=%@",param,[panel getValueForParam:param]];
                }
                [panel pushIntoWebview:mstring];
            }
        }
        return @"1";
    };
    
    return [paramExpanedBlock copy];
    
}


- (NSString *)doExecute:(WSLuaScriptEnter *)executerEnter{
    
    return [executerEnter runGenerateURL];
    
}
@end
