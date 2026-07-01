//
//  WSVisitRecordDetail.h
//  WinSFA
//
//  Created by Nemo on 14-4-4.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define visit_record_detail_acvtName     @"acvtname"
#define visit_record_detail_qsts         @"context"
//#define visit_record_detail_qstName      @"qstname"
//#define visit_record_detail_qstValue     @"val"

@interface WSVisitRecordAcvt : NSObject


@property (nonatomic,strong)    NSString *acvtName;
//@property (nonatomic,strong)    NSString *qstName;
//@property (nonatomic,strong)    NSString *qstValue;
@property (nonatomic,strong)    NSArray  *qstArray;



/**
 * 根据dic来构造WSVisitRecordDetail
 */
- (void)fillByDic:(NSDictionary*)dic;

@end
