//
//  WSDataSourceForDSSpestore.m
//  WinSFA
//
//  Created by yang on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDataSourceFromDSSpestore.h"

@implementation WSDataSourceFromDSSpestore

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    if ([[buildInfo getDataSource] isEqualToString:@"spestore" ]) {
        // to do something
        self.dataSourceArray = [WSAppData getObjectbyKey:@"spestore"];
    }
    return self.dataSourceArray;
}

@end
