//
//  WSListDataSourceFromOpt.m
//  WinSFA
//
//  Created by yang on 15-3-19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromOpt.h"

@implementation WSDataSourceFromOpt

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([buildInfo getOptArray] && [[buildInfo getOptArray] count] > 0) {
        
        self.dataSourceArray = [buildInfo getOptArray];
        
    }
    
    
    return self.dataSourceArray;
}

@end
