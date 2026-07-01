//
//  WSAcvtDataGridComponentView.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataGridComponent.h"
#import "WSTableItem.h"
#import "WSFuncsBean_Param.h"
#import "WSAcvtDataGridComponentDataSource.h"
//===============================================================================================================================================================================

@interface WSAcvtDataGridComponentView : DataGridComponent
@property (nonatomic, assign) BOOL insertAcvtDataGridIsSucceed;
@property (nonatomic, strong) NSMutableArray *deletedProds;

- (void)uploadWithAcvtMD5:(NSString *)acvtMD5 andId:(NSString *)idMD5;
- (void)removeDeletedProdsWhenUpload;
- (void)setReadonly:(BOOL)readonly isInitFisrt:(BOOL)isFirst;
- (void)deleteProdsWithIndex:(NSIndexSet *)indexSet andSelectionSet:(NSSet *)selectionSet;
- (WSAcvtDataGridComponentDataSource *)getAcvtDataSource;
- (NSString *)acvtDataGridQstId;

@end
//===============================================================================================================================================================================
