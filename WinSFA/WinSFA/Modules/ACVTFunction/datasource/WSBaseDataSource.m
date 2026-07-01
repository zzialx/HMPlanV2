//
//  WSBaseDataSource.m
//  WinSFA
//
//  Created by yang on 15-3-20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDataSource.h"


@implementation WSBaseDataSource

@synthesize dataSourceArray = _dataSourceArray;

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    return nil;
}

- (NSArray *)getDataSourceByFilter:(NSString *)filter
{
    return nil;
}

- (NSString *)getTempEmpId{
    
    return self.tempEmpId;
    
}

- (WSStoreBean *)getTempStore{
    
   return  self.tempStore;
    
}

- (void)setTempEmpId:(NSString *)tempEmpId{
    
    _tempEmpId = tempEmpId;
}

- (void)setTempStore:(WSStoreBean *)tempStore{
    
    _tempStore = tempStore;
    
}

- (void)setParentSelectedItemID:(NSString *)parentSelectedItemID {
    _parentSelectedItemID = parentSelectedItemID;
}

@end
