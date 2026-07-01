//
//  WSDutyBean.m
//  WinSFA
//
//  Created by heju on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDutyBean.h"

@implementation WSDutyBean

- (id)initWithObjec:(id)object {
    if (object == nil){
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            // to  do something
            _col3 = [object objectForKey:@"col3"];
            
            _col4 = [object objectForKey:@"col4"];
            
            id empId  = [object objectForKey:@"empId"];
            _empId = [empId integerValue];
            _bizDate = [object objectForKey:@"bizDate"];
            NSString *morningString = [object objectForKey:@"morning"];
            if (morningString && [morningString isKindOfClass:[NSNumber class]]) {
                _morning =  [NSString stringWithFormat:@"%ld",(long)[morningString integerValue]];
            } else if (morningString && [morningString isKindOfClass:[NSString class]]) {
                _morning = morningString;
            }
            
            NSString *afternoonString = [object objectForKey:@"afternoon"];
            if (afternoonString && [afternoonString isKindOfClass:[NSNumber class]]) {
                _afternoon = [NSString stringWithFormat:@"%ld",(long)[afternoonString integerValue]];
            } else if (afternoonString && [afternoonString isKindOfClass:[NSString class]]) {
                _afternoon = afternoonString;
            }
            
            _rate = [object objectForKey:@"rate"];
            _rateColor = [object objectForKey:@"color"];
            
            NSArray *dateArray = [_bizDate componentsSeparatedByString:@"-"];
            if ([dateArray count] == 3) {
                
                _year = [dateArray objectAtIndex:0];
                _month = [dateArray objectAtIndex:1];
                _day = [dateArray objectAtIndex:2];
            
            }
        }
    }
    return self;
}

@end
