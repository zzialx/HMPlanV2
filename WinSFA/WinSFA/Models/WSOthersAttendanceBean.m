//
//  WSOthersAttendanceBean.m
//  WinSFA
//
//  Created by xiajl on 15/6/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSOthersAttendanceBean.h"

@implementation WSOthersAttendanceBean

- (id)initWithObjec:(id)object {
    if (object == nil){
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            // to  do something
            _ODTYPE_NAME = [object objectForKey:@"ODTYPE_NAME"];
            _biz_date = [object objectForKey:@"biz_date"];
            id empId  = [object objectForKey:@"empId"];
            _empId = [empId integerValue];
            id odtimeId  = [object objectForKey:@"ODTIME_ID"];
            _ODTIME_ID = [odtimeId integerValue];
            _ODTIME_NAME = [object objectForKey:@"ODTIME_NAME"];
            _DOC_DATE = [object objectForKey:@"DOC_DATE"];
            id odtypeId = [object objectForKey:@"ODTYPE_ID"];
            _ODTYPE_ID = [odtypeId integerValue];
            _atdc_value = [object objectForKey:@"atdc_value"];
        }
    }
    return self;
}

@end
