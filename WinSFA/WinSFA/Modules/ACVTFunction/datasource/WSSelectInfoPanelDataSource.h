//
//  WSSelectInfoPanelDataSource.h
//  WinSFA
//
//  Created by winchannel on 15/5/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_DataSource.h"

@interface WSSelectInfoPanelDataSource : NSObject<I_W_DataSource>
@property (nonatomic,strong) WSStoreBean  *currentStore;
@property (nonatomic, strong) NSArray *dataSourceArray;
@end
