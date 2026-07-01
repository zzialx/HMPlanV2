//
//  WSGetDurationStoreTimeExecutor.m
//  WinSFA
//
//  Created by heju on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSGetDurationStoreTimeExecutor.h"

#import "WSAcvtViewController.h"

#import "WSInoutStoreTable.h"

#import "WSAcvtView.h"
#import "WSBaseModel.h"

@implementation WSGetDurationStoreTimeExecutor

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
                NSString *enterTime = [NSString stringWithValue:[[WSInoutStoreTable sharedTable] getEnterStoreTime:acvtViewController.currentStore andOtherParam:acvtViewController.model.md5 andParamType:EParameterType_VisitId]] ;
//                double serverTime = [[WSCurrentTime getServerTime] doubleValue];
                double time = ([[WSCurrentTime getServerTime] doubleValue] - [enterTime doubleValue]);
                NSString *durationTime = [NSString stringWithFormat:@"%@",[WSCurrentTime getTimeDifferencebydif:time]];
                return durationTime;
            }
    
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}


@end
