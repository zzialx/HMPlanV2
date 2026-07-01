//
//  WCLogger.h
//  xiaonei
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDLog.h"

#define LogAsync        YES
#define LogContext      0

//level
/*
 LOG_LEVEL_VERBOSE
 LOG_LEVEL_INFO
 LOG_LEVEL_WARN
 LOG_LEVEL_ERROR
 LOG_LEVEL_OFF
 */
// 使用 LogError LogWarn LogInfo LogVerbose 进行调试输出。LogCError等版本用于在C风格函数中使用
//控制打印LOG的等级，可选项为上面五个，关掉LOG，则为LOG_LEVEL_OFF
#define WCLogLevel  LOG_LEVEL_VERBOSE
#define THIS_FILE_NAME  [WCLogger ExtractFileNameWithoutExtension:__FILE__ needCopy:NO]


static const int ddLogLevel = WCLogLevel;

#define LOG_C_MAYBE(async, lvl, flg, ctx, frmt, ...) \
LOG_MAYBE(async, lvl, flg, ctx, __FUNCTION__, frmt, ##__VA_ARGS__)


#define LogObjc(flg, frmt, ...) LOG_OBJC_MAYBE(LogAsync, ddLogLevel, flg, LogContext, frmt, ##__VA_ARGS__)
#define LogC(flg, frmt, ...)    LOG_C_MAYBE(LogAsync, ddLogLevel, flg, LogContext, frmt, ##__VA_ARGS__)





#if ((WCLogLevel &  LOG_LEVEL_ERROR) == LOG_LEVEL_ERROR)
#define LogError(frmt, ...)     LogObjc(LOG_FLAG_ERROR,   (@"[ERROR]%@,%@ " frmt), THIS_FILE_NAME,THIS_METHOD,  ##__VA_ARGS__)
#define LogCError(frmt, ...)    LogC(LOG_FLAG_ERROR,   (@"[ERROR]%@,%s " frmt), THIS_FILE_NAME, __FUNCTION__,##__VA_ARGS__)
#define LogDebug(frmt, ...)   LogObjc(LOG_FLAG_ERROR, (@"[DEBUG]%@,%@ " frmt), THIS_FILE_NAME,THIS_METHOD, ##__VA_ARGS__)
#define LogCDebug(frmt, ...)    LogC(LOG_FLAG_ERROR,   (@"[DEBUG]%@,%s " frmt), THIS_FILE_NAME, __FUNCTION__,##__VA_ARGS__)
#else
#define LogError(frmt,...)  do { } while (0)
#define LogCError(frmt,...) do { } while (0)
#define LogDebug(frmt, ...) do { } while (0)
#define LogCDebug(frmt,...) do { } while (0)
#endif

#if ((WCLogLevel &  LOG_LEVEL_WARN) == LOG_LEVEL_WARN)
#define LogWarn(frmt, ...)      LogObjc(LOG_FLAG_WARN,    (@"[WARN]%@,%@ " frmt), THIS_FILE_NAME,THIS_METHOD, ##__VA_ARGS__)
#define LogCWarn(frmt, ...)     LogC(LOG_FLAG_WARN,    (@"[WARN]%@,%s " frmt), THIS_FILE_NAME,__FUNCTION__, ##__VA_ARGS__)
#else
#define LogWarn(frmt, ...)   do { } while (0)
#define LogCWarn(frmt, ...)  do { } while (0)
#endif


#if ((WCLogLevel &  LOG_LEVEL_INFO) == LOG_LEVEL_INFO)
#define LogInfo(frmt, ...)      LogObjc(LOG_FLAG_INFO,    (@"[INFO]%@,%@ " frmt), THIS_FILE_NAME,THIS_METHOD, ##__VA_ARGS__)
#define LogCInfo(frmt, ...)     LogC(LOG_FLAG_INFO,    (@"[INFO]%@,%s" frmt), THIS_FILE_NAME, __FUNCTION__,##__VA_ARGS__)
#define LogTrace() LogObjc(LOG_FLAG_INFO,    (@"[TRACE]%@(class:%@),%@ "), THIS_FILE_NAME,NSStringFromClass([self class]),THIS_METHOD)
#else
#define LogInfo(frmt, ...)   do { } while (0)
#define LogCInfo(frmt, ...)  do { } while (0)
#define LogTrace() do { } while (0)
#endif

#if ((WCLogLevel &  LOG_LEVEL_VERBOSE) == LOG_LEVEL_VERBOSE)
#define LogVerbose(frmt, ...)   LogObjc(LOG_FLAG_VERBOSE, (@"[VERBOSE]%@,%@ " frmt), THIS_FILE_NAME,THIS_METHOD, ##__VA_ARGS__)
#define LogCVerbose(frmt, ...)  LogC(LOG_FLAG_VERBOSE, (@"[BERBOSE]%@,%s " frmt), THIS_FILE_NAME,__FUNCTION__, ##__VA_ARGS__)
#else
#define LogVerbose(frmt, ...)  do { } while (0)
#define LogCVerbose(frmt, ...) do { } while (0)
#endif

#define LogPostData(postData,stringLength) {\
NSString *logString = [[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding];\
if(logString.length>stringLength){\
logString = [logString substringToIndex:stringLength];\
}\
LogInfo(@">>>>>>>>>>request-post<<<<<<<<\n%@\n",logString);\
}

#define LogResponseString(responseString,stringLength){\
NSString *logString = responseString;\
if(logString.length>stringLength){\
    logString = [responseString substringToIndex:stringLength];\
}\
LogInfo(@">>>>>>>>>>response<<<<<<<<<\n%@\n",logString);\
}

#define LogSQLString(sqlString){\
LogInfo(@">>>>>>>>>>exec sql<<<<<<<<<\n%@\n",sqlString);\
}

@interface WCLogger : NSObject

+(NSString *)ExtractFileNameWithoutExtension:(const char *)filePath needCopy:(BOOL) copy;

@end

