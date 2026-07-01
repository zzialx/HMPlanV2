//
//  WSDateAndTimeDisplayValue.m
//  WinSFA
//
//  Created by Stephanie on 16/5/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDateDisplayValue.h"
#import "I_W_BuildInfo.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "NSDate+Additions.h"

#define kNull @"null"

@implementation WSDateDisplayValue

- (NSObject *)getDisplayValueFor:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    NSObject *disValue = [super getDisplayValueFor:buildInfo];
    NSString *defaultString = nil;
    BOOL isShowDate = YES;
    if ([disValue isKindOfClass:[NSString class]] || !disValue) {
        
        NSString *str;
        if ([disValue isKindOfClass:[NSString class]]) {
            str = (NSString *)disValue;
        }
        else {
            str = [buildInfo getDefaultValue];
        }
        
        if ([str isEqualToString:kNull] || [str isEqualToString:@"0"]) {
            isShowDate = NO;
            disValue = nil;
        }
        else if ([str isPureNumber]) {
            defaultString = str;
            disValue = nil;
        }
    }
    
    if (isShowDate) {
        
        if (!disValue) {
     
            NSString *qstType = [buildInfo getAcvtQstType];
            disValue = [WSDateDisplayValue getDisplayValueByQstType:qstType defaultString:defaultString];
            if ([qstType isEqualToString:@"SE"] || [qstType isEqualToString:@"TT"]) {
                
                BOOL isSinglePicker = NO;
                if (![[buildInfo getMlen] isEqualToString:@"0"]) {
                    isSinglePicker = YES;
                }
                
                if (!isSinglePicker) {
                    NSArray *disPlayValues = [NSArray arrayWithObjects:disValue, disValue, nil];
                    disValue = [disPlayValues componentsJoinedByString:@","];
                }
            }
        }
    }

    return disValue;
}

+ (NSString *)getDisplayValueByQstType:(NSString *)qstType defaultString:(NSString *)defaultString {
    
    NSDate *date = [WSDateDisplayValue getDateByQstType:qstType defaultString:defaultString];
    return [WSDateDisplayValue formatDateByType:qstType date:date];
}


+ (NSDate *)getDateByQstType:(NSString *)qstType defaultString:(NSString *)defaultString {
    
    NSDate *date = [WSCurrentTime getCurrentServerDate];
    if ([defaultString length] == 0 || [defaultString isEqualToString:@"0"]) {
        return date;
    }
    
    NSInteger defaultValue = [defaultString integerValue];
    if ([qstType isEqualToString:@"D"]) {
        date = [date ws_dateAddingByDay:defaultValue];
    }
    else if ([qstType isEqualToString:@"YM"]) {
        date = [date ws_dateAddingByMonth:defaultValue];
    }
    else if ([qstType isEqualToString:@"Y"]) {
        date = [date ws_dateAddingByYear:defaultValue];
    }
   
    return date;
}

+ (NSString *)formatDateByType:(NSString *)qstType date:(NSDate *)date {
    
    NSString *dateStr;
    if ([qstType isEqualToString:@"D"] || [qstType isEqualToString:@"SE"]) {
        dateStr = [WSCurrentTime getDateStringWithTime:date];
    }
    else if ([qstType isEqualToString:@"DT"]) {
        dateStr = [WSCurrentTime getShortTimeStringWithTime:date];
    }
    else if ([qstType isEqualToString:@"TT"]) {
        dateStr = [WSCurrentTime getDateTimeWithTime:date];
    }
    else if ([qstType isEqualToString:@"YM"]) {
        dateStr = [WSCurrentTime getMonthStringWithTime:date];
    }
    else if ([qstType isEqualToString:@"Y"]) {
        dateStr = [WSCurrentTime getYearStringWithTime:date];
    }
    else if ([qstType isEqualToString:@"WF"]) {
        dateStr = [WSCurrentTime getDateTimeWithTime:date];
    }
    
    return dateStr;
}

@end
