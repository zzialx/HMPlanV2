//
//  WSProductTable.m
//  WinSFA
//
//  Created by zhangke on 14/9/17.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSProductTable.h"

@implementation WSProductTable

static WSProductTable *fdtTable=nil;
+(WSProductTable*)sharedTable
{
    @synchronized(self) {
        if (fdtTable==nil) {
            fdtTable= [[WSProductTable alloc]init];
        }
    }
    return  fdtTable;
}

- (void)deleteProductWithGenId:(NSString *)genId prodIds:(NSArray *)prodIds {
    if (genId == nil) {
        LogInfo(@"genId is nil");
        return;
    }
    
    NSString *inCondition = @"";
    if ([prodIds count] > 0) {
        inCondition = @"and PROD_ID in ";
        inCondition = [inCondition stringByAppendingString:@"("];
        for (NSInteger i = 0; i < [prodIds count]; i++) {
            if (i == 0) {
                inCondition = [inCondition stringByAppendingFormat:@"'%@'",prodIds[i]];
                
            }else {
                inCondition = [inCondition stringByAppendingFormat:@",'%@'",prodIds[i]];
            }
        }
        inCondition = [inCondition stringByAppendingString:@")"];
    }
    
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from wch_product where IDX = '%@' %@ ",genId,inCondition];
    
    [[WSProductTable sharedTable] executeUpdateWithSqls:@[deleteSql]];
    
}


@end
