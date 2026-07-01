//
//  WSWSEditableAcvtQstBeanArray.h
//  WinSFA
//
//  Created by yang on 16/1/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseBeanArray.h"

@interface WSEditableAcvtQstBeanArray : WSBaseBeanArray

- (NSString *)getValueByGenID:(NSString *)genID acvtID:(NSString *)acvtID acvtQstID:(NSString *)acvtQstID;

- (void)addDataByGenID:(NSString *)genID acvtID:(NSString *)acvtID acvtQstID:(NSString *)acvtQstID value:(NSString *)value qstID:(NSString *)qstID;

@end
