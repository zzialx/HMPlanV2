//
//  WSBdLocationDataTable.m
//  WinSFA
//
//  Created by Alicia on 2017/8/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBdLocationDataTable.h"

@implementation WSBdLocationDataTable

- (void)cleanOldData {
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    NSArray *whereNames=[NSArray arrayWithObjects:@"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:currenTime, nil];
    
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}


- (NSArray *)queryWithCurrentEmpId {
    NSString *empid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    return  [self queryWithNames:@[@"emp_id"] ArgumentsValue:@[empid]];
}


- (void)insertWithLocation:(WSLocationDescribe *)locationDescribe withTimeStamp:(NSNumber *)timeStamp withDateTimeString:(NSString *)dateTimeString
{
    LogInfo(@"---bdlocationDatatable666---");
    if (locationDescribe.location) {
        LogInfo(@"---bdlocationDatatable777---满足入库条件---");
        NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        NSString *bizDate = [WSCurrentTime getDateString];
        NSString *addr = [NSString stringNotNilWithValue:locationDescribe.detailAddress];
        NSString *lon = [NSString stringWithFormat:@"%lf", locationDescribe.location.coordinate.longitude];
        NSString *lat = [NSString stringWithFormat:@"%lf", locationDescribe.location.coordinate.latitude];
        NSString *locTime = [NSString stringWithFormat:@"%.0lf", [timeStamp doubleValue]];
        NSString *locCity = [NSString stringNotNilWithValue:locationDescribe.cityName];
        NSString *province = [NSString stringNotNilWithValue:locationDescribe.provinceName];
        NSString *district = [NSString stringNotNilWithValue:locationDescribe.subLocality];

        NSArray *queryArray = [self queryWithCurrentEmpId];
        if ([queryArray count] > 0) {
            [self deleteWithNames:@[@"emp_id"] ArgumentsValue:@[empId]];
        }
        [self insertWithArgumentsValue:@[empId, bizDate, lon, lat, locTime, addr, dateTimeString,locCity,province,district]];
    } else {
        LogError(@"locationDescribe is null");
    }
}


@end
