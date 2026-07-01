//
//  WSVisitRecord.h
//  WinSFA
//
//  Created by Nemo on 14-4-3.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define     visit_record_empname    @"empname"
#define     visit_record_bizdate    @"bizdate"
#define     visit_record_context    @"acvt"

@interface WSVisitRecord : NSObject
{
}

@property (nonatomic, strong) NSString *empName;
@property (nonatomic, strong) NSString *bizDate;
@property (nonatomic, strong) NSArray  *recordDetails;


/**
 * 根据dic来构造WSVisitRecord
 */
- (void)fillByDic:(NSDictionary*)dataDic;

@end
