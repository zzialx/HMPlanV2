//
//  WSTAAcvtDataGridViewDataSouce.m
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSTAAcvtDataGridViewDataSouce.h"

#import "WSTAAcvtDataGridComponentDataSource.h"

@implementation WSTAAcvtDataGridViewDataSouce


- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    
    WSTAAcvtDataGridComponentDataSource *dataGridDataSouce = [[WSTAAcvtDataGridComponentDataSource alloc] initWith:buildInfo];
    
    return dataGridDataSouce;
    
}



@end
