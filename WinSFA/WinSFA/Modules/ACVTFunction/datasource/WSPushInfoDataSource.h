//
//  WSPushInfoDataSource.h
//  WinSFA
//
//  Created by xiajl on 15/4/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_DataSource.h"
#import "WSBaseDataSource.h"


@interface WSPushInfoDataSource : WSBaseDataSource <I_W_DataSource>

- (NSArray *) getHeadDataSourceFor;

@end
