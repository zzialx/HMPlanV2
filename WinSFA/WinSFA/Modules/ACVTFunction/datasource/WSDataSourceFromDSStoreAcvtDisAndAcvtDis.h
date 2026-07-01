//
//  WSDataSourceFromDSStoreAcvtDisAndAcvtDis.h
//  WinSFA
//
//  Created by Stephanie on 16/9/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseDataSource.h"

@interface WSDataSourceFromDSStoreAcvtDisAndAcvtDis : WSBaseDataSource

- (NSArray *)getDataSourceByFilter:(NSString *)filter storeID:(NSString *)storeID;

@end
