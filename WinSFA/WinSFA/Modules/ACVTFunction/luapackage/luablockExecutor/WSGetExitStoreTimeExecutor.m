//
//  WSGetExitStoreTimeExecutor.m
//  WinSFA
//
//  Created by heju on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSGetExitStoreTimeExecutor.h"

#import "WSCurrentTime.h"



@implementation WSGetExitStoreTimeExecutor


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
                return [WSCurrentTime getTimeStringbyMills:[[WSCurrentTime getServerTime] doubleValue]];
            }
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}



@end
