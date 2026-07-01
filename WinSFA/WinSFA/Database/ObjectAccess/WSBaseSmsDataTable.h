//
//  WSBaseSmsDataTable.h
//  WinSFA
//
//  Created by mac on 16/12/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseSmsDataTable : WSSqliteUtil
-(BOOL)insertDataWithContent:(NSString *)content receiver:(NSArray *)recivers result:(NSString * )result;
@end
