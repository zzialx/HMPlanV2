//
//  WSSLDataSourceFromSubEmpStore.m
//  WinSFA
//
//  Created by Alicia on 2018/3/1.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSLDataSourceFromSubEmpStore.h"
#import "WSSubempstoreBeanArray.h"
#import <UIKit/UIKit.h>

@implementation WSSLDataSourceFromSubEmpStore

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo {
    NSString *filter = [buildInfo getFilterCondition];
    if ([filter length] > 0) {
        WSSubempstoreBeanArray *subempStoreBeanArray = [WSAppData getObjectbyKey:filter];

        self.dataSourceArray = [[NSMutableArray alloc] initWithArray:subempStoreBeanArray.subempstoreArray copyItems:YES];
    }
    return self.dataSourceArray;
}



@end
