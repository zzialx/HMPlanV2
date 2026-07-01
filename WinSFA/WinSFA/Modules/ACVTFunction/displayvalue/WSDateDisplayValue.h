//
//  WSDateAndTimeDisplayValue.h
//  WinSFA
//
//  Created by Stephanie on 16/5/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDefaultStringDisplayValue.h"

@interface WSDateDisplayValue : WSDefaultStringDisplayValue

+ (NSString *)getDisplayValueByQstType:(NSString *)qstType defaultString:(NSString *)defaultString;

@end
