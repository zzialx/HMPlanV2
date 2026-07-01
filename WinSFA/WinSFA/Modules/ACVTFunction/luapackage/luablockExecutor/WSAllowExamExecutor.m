//
//  WSAllowExamExecutor.m
//  WinSFA
//
//  Created by xiajl on 15/5/7.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//
#import "WinSFA.h"
#import "WSAllowExamExecutor.h"
#import "WSLuaScriptEnter.h"
#import "WSDPListWithEmbedQAPanel.h"
#import "WSSelectInformationPanel.h"



@implementation WSAllowExamExecutor

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
        NSString *qstNameString = [NSString stringWithFormat:@"%@" ,firstObj];
      id temp = [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstNameString];
        if ([temp isKindOfClass:[WSDPListWithEmbedQAPanel class]]) {
            WSDPListWithEmbedQAPanel  * panel = (WSDPListWithEmbedQAPanel *)temp;
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            NSString *methodStr = [NSString stringWithFormat:@"%@",secondObj];
            va_end(argsList);
            if (methodStr) {
                SEL selector1 = NSSelectorFromString(methodStr);
                if (selector1 && [panel respondsToSelector:selector1]) {
                    NSString *stringresult = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    stringresult = [NSString stringWithFormat:@"%@",[panel performSelector:selector1]];
#pragma clang diagnostic pop
                    
                    NSLog(@"stringresult = %@",stringresult);
                    return stringresult;
                }
            }
        }else if ([temp isKindOfClass:[WSSelectInformationPanel class]]){
            WSSelectInformationPanel  * panel =  (WSSelectInformationPanel *)temp;
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            NSString *methodStr = [NSString stringWithFormat:@"%@",secondObj];
            if (methodStr){
                id args = va_arg(argsList, id);
                 va_end(argsList);
                if ([args isKindOfClass:[NSArray class]]) {
                    NSArray *array = (NSArray *)args;
                    NSString *isAllow = @"0";
                    if ([[NSString stringWithFormat:@"%@",[array objectAtIndex:0]] isEqualToString:@"1"]) {
                        isAllow = @"1";
                    }
                    if([isAllow isEqualToString:@"1"]){
                        if (methodStr) {
                            SEL selector1 = NSSelectorFromString(methodStr);
                            if ([panel respondsToSelector:selector1]) {
                                SuppressPerformSelectorLeakWarning(
                                                                   [panel performSelector:selector1];
                                );
                                return @"1";
                            }
                        }
                    }
                }
                
            } else {
                va_end(argsList);
            }
        }
        return @"1";
    };
    
    return [paramExpanedBlock copy];
    
}


- (NSString *)doExecute:(WSLuaScriptEnter *)executerEnter{
    
    return [executerEnter runAllowExam];
    
}
@end
