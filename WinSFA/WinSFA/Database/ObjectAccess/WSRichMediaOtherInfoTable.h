//
//  WSRichMediaOtherInfoTable.h
//  WinSFA
//
//  Created by yang on 17/1/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSRichMediaOtherInfoTable : WSSqliteUtil

+ (WSRichMediaOtherInfoTable *)sharedTable;


- (void)cleanOldData;


- (BOOL)insertClickTimeWithStoreId:(NSString *)storeId richMediaId:(NSString *)richMediaId clickTime:(NSString *)clickTime;

- (NSString *)getClickTimeWithStoreId:(NSString *)storeId richMediaId:(NSString *)richMediaId;

//- (NSArray *)getMediaInfoArrayWithStoreId:(NSString *)storeId;

@end
