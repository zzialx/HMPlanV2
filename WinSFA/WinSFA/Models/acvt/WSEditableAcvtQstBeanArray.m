//
//  WSWSEditableAcvtQstBeanArray.m
//  WinSFA
//
//  Created by yang on 16/1/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEditableAcvtQstBeanArray.h"
#import "WSEditableAcvtQstBean.h"

@implementation WSEditableAcvtQstBeanArray

- (Class)getBeanSubclass
{
    return [WSEditableAcvtQstBean class];
}


- (NSString *)getDefaultParseKey
{
    return EDITABLE_ACVTQST;
}

- (NSString *)getValueByGenID:(NSString *)genID acvtID:(NSString *)acvtID acvtQstID:(NSString *)acvtQstID
{
    NSString *value = nil;
    
    NSString *empID = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    for (WSEditableAcvtQstBean *qstBean in self.beanArray) {
        if ([genID isEqualToString:qstBean.genID] &&
            [acvtID isEqualToString:qstBean.acvtId] &&
            [acvtQstID isEqualToString:qstBean.acvtQstId] &&
            [empID isEqualToString:qstBean.empId]) {
            value = qstBean.value;
            break;
        }
    }
    
    return value;
}

- (void)addDataByGenID:(NSString *)genID acvtID:(NSString *)acvtID acvtQstID:(NSString *)acvtQstID value:(NSString *)value qstID:(NSString *)qstID
{
    WSEditableAcvtQstBean *bean = [[WSEditableAcvtQstBean alloc] init];
    bean.genID = genID;
    bean.acvtId = acvtID;
    bean.value = value;
    bean.qstId = qstID;
    bean.acvtQstId = acvtQstID;
    bean.empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    [self.beanArray addObject:bean];
}

@end
