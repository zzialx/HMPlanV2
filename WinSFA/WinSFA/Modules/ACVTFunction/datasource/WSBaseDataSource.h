//
//  WSBaseDataSource.h
//  WinSFA
//
//  Created by yang on 15-3-20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_DataSource.h"

@interface WSBaseDataSource : NSObject<I_W_DataSource>

@property (nonatomic, strong) WSStoreBean *tempStore;

@property (nonatomic, strong) NSString *tempEmpId;

@property (nonatomic,retain) NSString *parentSelectedItemID;

- (NSArray *)getDataSourceByFilter:(NSString *)filter;

- (NSArray *)getDataSourceByFilter:(NSString *)filter andBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo;
@end
