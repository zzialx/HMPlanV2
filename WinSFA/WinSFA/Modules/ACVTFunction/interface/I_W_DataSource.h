//
//  I_W_DataSouce.h
//  WinSFA
//
//  Created by winchannel on 15/3/7.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "I_W_BuildInfo.h"
#ifndef WinSFA_I_W_DataSource_h
#define WinSFA_I_W_DataSource_h

@protocol I_W_DataSource <NSObject>

@property (nonatomic, strong) NSArray *dataSourceArray;

-(NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo;

@optional

- (NSString *)getTempEmpId;

- (WSStoreBean *)getTempStore;

- (void)setTempEmpId:(NSString *)tempEmpId;

- (void)setTempStore:(WSStoreBean *)tempStore;

- (void)setParentSelectedItemID:(NSString *)parentSelectedItemID;

@end


#endif
