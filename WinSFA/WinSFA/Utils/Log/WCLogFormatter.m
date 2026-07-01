//
//  WCLogFormatter.m
//  WinSFA
//
//  Created by yang on 13-7-17.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WCLogFormatter.h"

@interface WCLogFormatter ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation WCLogFormatter

-(NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    //    NSString *logLevel;
    //
    //    switch (logMessage->_flag) {
    //
    //        case LOG_FLAG_ERROR:    logLevel = @"Error"; break;
    //        case LOG_FLAG_WARN:     logLevel = @"Warn"; break;
    //        case LOG_FLAG_INFO:     logLevel = @"Info"; break;
    //        case LOG_FLAG_VERBOSE:  logLevel = @"Verbose"; break;
    //        default:                logLevel = @"Verbose"; break;
    //
    //    }
    
    return [NSString stringWithFormat:@"%@ %@ [line %@]%@\n",[self.dateFormatter stringFromDate:logMessage->_timestamp], logMessage->_function, @(logMessage->_line), logMessage->_message];
}

-(NSDateFormatter *)dateFormatter
{
    if (nil == _dateFormatter) {
        _dateFormatter = [NSDateFormatter standardDateFormatter];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return _dateFormatter;
}

@end
