//
//  WSAcvtDataGridViewDataSource.m
//  WinSFA
//
//  Created by yang on 15/4/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridViewDataSource.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"

@implementation WSAcvtDataGridViewDataSource

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
 
    WSAcvtDataGridComponentDataSource *dataSource = [[WSAcvtDataGridComponentDataSource alloc] initWithQst:(WSAcvtBean_qst *)buildInfo store:model.currentStore func:model.currentFuncs ownViewController:model.ownAcvtViewController isInNewAcvt:model.isNewAddAcvt];
 
    
    dataSource.isClear = YES;
    
    return dataSource;
}

@end
