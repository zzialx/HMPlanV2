//
//  WSVisitRecordDetail.m
//  WinSFA
//
//  Created by Nemo on 14-4-4.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSVisitRecordAcvt.h"
#import "WSAcvtBean_qst.h"

@implementation WSVisitRecordAcvt


/**
 * 根据dic来构造WSVisitRecordAcvt
 */
- (void)fillByDic:(NSDictionary*)dic
{
    if (!dic) { return; }
    if ([[dic allKeys] count] <  1) {   return; }
    
    _acvtName = [dic objectForKey:visit_record_detail_acvtName];
   _qstArray = [dic objectForKey:visit_record_detail_qsts];
//    _qstName = [dic objectForKey:visit_record_detail_qstName];
//    _qstValue = [dic objectForKey:visit_record_detail_qstValue];
}

@end












