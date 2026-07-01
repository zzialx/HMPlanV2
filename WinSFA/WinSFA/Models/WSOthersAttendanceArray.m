//
//  WSOthersAttendanceArray.m
//  WinSFA
//
//  Created by xiajl on 15/6/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSOthersAttendanceArray.h"
#import "WSOthersAttendanceBean.h"

@implementation WSOthersAttendanceArray
-(void)initDutyWithArray:(NSArray*)array
{
    _otherAttendanceArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            for (int i = 0; i < [array count]; i++) {
                WSOthersAttendanceBean *dutyBean = [[WSOthersAttendanceBean alloc]initWithObjec:[array objectAtIndex:i]];
                [self.otherAttendanceArray insertObject:dutyBean atIndex:i];
            }
        }
    }
}
-(id)initWithObject:(id)object
{
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSArray *Array = [object objectForKey:DUTY_OTHERSATTENDANCE];
            [self initDutyWithArray:Array];
        }
        return self;
    }
    return nil;
}
@end
