//
//  WSBarCodeScanDisplayValue.m
//  WinSFA
//
//  Created by yang on 15/4/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCodeScanDisplayValue.h"
#import "WSStoreAcvtDisArray.h"
#import "WSStoreAcvtDisBean.h"
#import "I_W_BuildInfo.h"

@implementation WSCodeScanDisplayValue


- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSStoreAcvtDisArray *storeAcvtDis =[WSAppData getObjectbyKey:STOREACVTDIS];
    
    NSMutableArray *tempSourceArray = [[NSMutableArray alloc]init];
    
    for (WSStoreAcvtDisBean *bean in storeAcvtDis.storeAcvtDisArray) {
        
        if (bean.m_p.count >3 ) {
            NSString *acvtQstId =[bean.m_p objectAtIndex:2];
            NSString *qstValue = [bean.m_p objectAtIndex:3];
            if ([[buildInfo getAcvtQstId] isEqualToString:acvtQstId]) {
                
                [tempSourceArray addObject:qstValue];
            }
        }
    }

    return [tempSourceArray componentsJoinedByString:@","];;
}

- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    return nil;
}

@end
