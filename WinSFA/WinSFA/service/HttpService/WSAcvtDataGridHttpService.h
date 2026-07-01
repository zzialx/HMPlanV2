//
//  WSAcvtDataGridHttpService.h
//  WinSFA
//
//  Created by yang on 15/4/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSAcvtViewController.h"

@class WSAcvtDataGridComponentDataSource;

@interface WSAcvtDataGridHttpService : NSObject

+ (NSString *)getAcvtGridJsonDataWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource acvtMD5:(NSString *)acvtMD5 tableMD5:(NSString *)tableMD5 isIgnoreNullValue:(BOOL)isIgnoreNullValue;

+ (BOOL)uploadAcvtGridPhotosWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource acvtMD5:(NSString *)acvtMD5 tableMD5:(NSString *)tableMD5  operationType:(WSOperationAcvtType)actionType;

@end
