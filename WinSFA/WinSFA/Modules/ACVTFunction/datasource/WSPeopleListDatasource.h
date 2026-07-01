//
//  WSPeopleListDatasource.h
//  WinSFA
//
//  Created by zhangke on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_DataSource.h"

@interface WSPeopleListDatasource : NSObject<I_W_DataSource>

@property (nonatomic,strong) WSStoreBean  *currentStore;

@property (nonatomic, strong) NSArray *dataSourceArray;

@end
