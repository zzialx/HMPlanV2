//
//  WSVisitRecord.m
//  WinSFA
//
//  Created by Nemo on 14-4-3.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSVisitRecord.h"
#import "WSVisitRecordAcvt.h"
@implementation WSVisitRecord

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/**
 * 根据dic来构造WSVisitRecord
 */
- (void)fillByDic:(NSDictionary*)dataDic
{
    _empName = [dataDic objectForKey:visit_record_empname];
    _bizDate = [dataDic objectForKey:visit_record_bizdate];
    _recordDetails = [dataDic objectForKey:visit_record_context];
}


@end
