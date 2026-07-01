//
//  WSCallQstWidgetMethodBaseExecutor.m
//  WinSFA
//
//  Created by yang on 17/1/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCallQstWidgetMethodBaseExecutor.h"
#import "WSWidget.h"
#import "I_W_BuildInfo.h"

@implementation WSCallQstWidgetMethodBaseExecutor

- (NSString *)callWidget:(WSWidget *)widget method:(NSString *)methodName paramObj:(id)paramObj
{
    NSString *result = nil;
    
    SEL selector1 = NSSelectorFromString(methodName);
    
    if ([widget respondsToSelector:selector1]) {
        
        if ([methodName hasSuffix:@":"]) {
            id argObj = nil;
            if ([paramObj isKindOfClass:[NSArray class]] && [paramObj count] > 0) {
                argObj = [paramObj firstObject];
            }
            
            if ([methodName hasPrefix:@"callGridMethodWithParams"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                result = [widget performSelector:selector1 withObject:argObj];
#pragma clang diagnostic pop
            }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [widget performSelector:selector1 withObject:argObj];
#pragma clang diagnostic pop
            }
            
        }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            result = [widget performSelector:selector1];
#pragma clang diagnostic pop
        }
        
        if (result) {
            result = [NSString stringWithFormat:@"%@",result];
        }
    }else {
        methodName = [NSString stringWithFormat:@"%@:", methodName];
        
        selector1 = NSSelectorFromString(methodName);
        
        if ([widget respondsToSelector:selector1] && paramObj) {
            id argObj = nil;
            if ([paramObj isKindOfClass:[NSArray class]] && [paramObj count] > 0) {
                argObj = [paramObj firstObject];
            }
            
            if ([methodName hasPrefix:@"callGridMethodWithParams"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                result = [widget performSelector:selector1 withObject:argObj];
#pragma clang diagnostic pop
            }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [widget performSelector:selector1 withObject:argObj];
#pragma clang diagnostic pop
            }
            LogInfo(@"拼接:后调用成功");
        } else {
             LogInfo(@"方法不识别，无法调用，尝试自己拼接:调用，拼接后：%@", methodName);
        }
    }
    
    return result;
}

- (NSString *)batchCallWidgets:(NSArray *)widgetArray method:(NSString *)methodName paramObj:(id)paramObj
{
    NSString *result = nil;
    WSWidget *tmpWidget = nil;
    
    for (id widget in widgetArray) {
        tmpWidget = widget;
        
        result = [self callWidget:widget method:methodName paramObj:paramObj];
    }
    
    if (!([result length] > 0)) {
        NSObject <I_W_BuildInfo> *buildInfo = [tmpWidget xbuildInfo];
        NSString *qstType = [buildInfo getAcvtQstType];
        if ([qstType isEqualToString:QST_TYPE_N] && ([methodName isEqualToString:@"getCurrentValue"] || [methodName isEqualToString:@"getDisplayValuePresentation"] || [methodName isEqualToString:@"getCurrentValuePresentation"])) {
            result = @"0";
        }else {
            result = @"";
        }
    }
    
    return result;
}

@end
