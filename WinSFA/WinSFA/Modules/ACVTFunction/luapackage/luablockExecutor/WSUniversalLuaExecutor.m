//
//  WSUniversalLuaExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSUniversalLuaExecutor.h"
#import "WSLuaScriptEnter.h"

@implementation WSUniversalLuaExecutor


- (NSString *)doExecute:(WSLuaScriptEnter *)executerEnter withParam:(NSString *)param {
    
    return [executerEnter runUniversalLuaFunction:param];
    
}

@end
