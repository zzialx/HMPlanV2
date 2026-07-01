//
//  WSDutyBeanArray.m
//  WinSFA
//
//  Created by heju on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDutyBeanArray.h"

@implementation WSDutyBeanArray

-(void)initDutyWithArray:(NSArray*)array
{
    _dutyArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            for (int i = 0; i < [array count]; i++) {
                WSDutyBean *dutyBean = [[WSDutyBean alloc]initWithObjec:[array objectAtIndex:i]];
                [self.dutyArray insertObject:dutyBean atIndex:i];
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
            __block NSMutableArray *Array = [NSMutableArray array];
            
            [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (key && [key isKindOfClass:[NSString class]] && ([key  isEqualToString:DUTY_ATTENDANCEDETAIL] || [key rangeOfString:DUTY_ATTENDANCEDETAIL].location != NSNotFound)) {
                    [Array addObjectsFromArray:(NSArray *)obj];
                }
            }];
            [self initDutyWithArray:Array];
        }
        return self;
    }
    return nil;
}

@end
