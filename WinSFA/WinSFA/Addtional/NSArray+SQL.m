//
//  NSArray+SQL.m
//  WinSFA
//
//  Created by yang on 17/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "NSArray+SQL.h"

@implementation NSArray (SQL)

- (NSString *)getInSqlString
{
    if (!self.count) {
        return nil;
    }
    
    NSString *inString = @" in (";
    for (NSInteger i = 0; i < [self count]; i++) {
        
        //YIHAIKERRY-3535  解决内存暴增
        @autoreleasepool {
            
            if (i == 0) {
                inString = [inString stringByAppendingFormat:@"'%@'",self[i]];
            }else {
                inString = [inString stringByAppendingFormat:@",'%@'",self[i]];
            }
            
        }
    }
    inString = [inString stringByAppendingString:@")"];
    
    return inString;
}

@end
