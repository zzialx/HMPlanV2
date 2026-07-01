//
//  WSGetEnterStoreTimeExecutor.m
//  WinSFA
//
//  Created by heju on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSGetEnterStoreTimeExecutor.h"

#import "WSInoutStoreTable.h"

#import "WSAcvtViewController.h"

#import "WSAcvtView.h"
#import "WSBaseModel.h"
#include <sys/time.h>

@implementation WSGetEnterStoreTimeExecutor




- (id)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        __strong __typeof(wself) sself = wself;
        NSLog(@"%@", firstObj);
        if (firstObj) {
            if (sself.delegate) {
                WSAcvtView *acvtView = (WSAcvtView *)sself.delegate;
                WSAcvtViewController *acvtViewController = (WSAcvtViewController *)acvtView.delegate;
                
                NSString* enterTime = [NSString stringWithValue:[[WSInoutStoreTable sharedTable] getEnterStoreTime:acvtViewController.currentStore andOtherParam:acvtViewController.model.md5 andParamType:EParameterType_VisitId]] ;
                
                if (enterTime != nil && ![enterTime isEqualToString:@""]) {
                    
                    return [WSCurrentTime getTimeStringbyMills:[enterTime doubleValue]];
                    
                }else{
                    
//                    return [WSCurrentTime getTimeStringbyMills:(double)[self getUSeconds]];
                    return [WSCurrentTime getTimeStringbyMills:[[WSCurrentTime getServerTime] doubleValue]];
                }
            }
            
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

- (NSString *)doExecute:(WSLuaScriptEnter *)executerEnter{
    
    return [executerEnter runUniversalLuaFunction:nil];
    
}
 
// 获取本地时间
- (long long)getUSeconds
{
    struct timeval time;
    gettimeofday(&time, NULL);
    return time.tv_sec;
}

@end
