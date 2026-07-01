//
//  WSVisitPlanArray.m
//  WinSFA
//
//  Created by yang on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSVisitPlanArray.h"
#import "WSVisitPlanBean.h"

@implementation WSVisitPlanArray

- (Class)getBeanSubclass
{
    return [WSVisitPlanBean class];
}


- (NSString *)getDefaultParseKey
{
    return STOREACVTDIS_VISITPLAN;
}

- (BOOL)isInplanStore:(NSString *)storeID
{
    BOOL isInPlan = NO;

    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    for (WSVisitPlanBean *visitPlanBean in self.beanArray) {
        if ([visitPlanBean.sId isEqualToString:storeID] && [visitPlanBean.next isEqualToString:bizDate] && [visitPlanBean.empId isEqualToString:empId]) {
            isInPlan = YES;
            break;
        }
    }
    
    return isInPlan;
}

@end
