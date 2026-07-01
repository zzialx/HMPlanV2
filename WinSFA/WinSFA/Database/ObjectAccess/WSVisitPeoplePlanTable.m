//
//  WSVisitPeoplePlanTable.m
//  WinSFA
//
//  Created by zhangke on 14-5-26.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSVisitPeoplePlanTable.h"


@implementation WSVisitPeoplePlanTable

static WSVisitPeoplePlanTable *visitPeoplePlanTable = nil;

+ (WSVisitPeoplePlanTable *)sharedTable
{
    if (visitPeoplePlanTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            visitPeoplePlanTable = [[WSVisitPeoplePlanTable alloc] init];
        });
    }
    
    return visitPeoplePlanTable;
}


- (void)insertVisitPlanWithArray:(NSArray *)array withDate:(NSString*)docDate
{
    NSString* empid= [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *whereN=[NSArray arrayWithObjects:@"docdate",@"empid", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:docDate], [NSString stringNotNilWithValue:empid], nil];
    [self deleteWithNames:whereN ArgumentsValue:whereV];
    
    for(NSDictionary* dic in array){
        
        NSMutableArray *aValArray = [[NSMutableArray alloc] init];

        NSString *docDate = [NSString stringWithValue:[dic valueForKey:@"docDate"]];
        NSString *empId = [NSString stringWithValue:[dic valueForKey:@"empId"]];
        NSString *subEmpId = [NSString stringWithValue:[dic valueForKey:@"subEmpId"]];
        NSString *subEmpName = [NSString stringWithValue:[dic valueForKey:@"subEmpName"]];
        NSString *subOrgId = [NSString stringWithValue:[dic valueForKey:@"subOrgId"]];
        NSString *subOrgName = [NSString stringWithValue:[dic valueForKey:@"subOrgName"]];

        [aValArray addObject:(docDate != nil) ? docDate : [NSNull null]];
        [aValArray addObject:(empId != nil) ? empId : [NSNull null]];
        [aValArray addObject:(subEmpId != nil) ? subEmpId : [NSNull null]];
        [aValArray addObject:(subEmpName != nil) ? subEmpName : [NSNull null]];
        [aValArray addObject:(subOrgId != nil) ? subOrgId : [NSNull null]];
        [aValArray addObject:(subOrgName != nil) ? subOrgName : [NSNull null]];

        [self insertWithArgumentsValue:aValArray];
    }
}


- (NSArray *)queryVisitPlanByDate:(NSString*)date
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *whereN=[NSArray arrayWithObjects:@"docDate",@"empid", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid], nil];
    
    return [self queryWithNames:whereN ArgumentsValue:whereV];
}


@end
