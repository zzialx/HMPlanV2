//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "WCLogManager.h"
#import "FileManager.h"
#import "WSEnvrionment.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";

NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;

const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;

const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace

{
    
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (
         
         i = UncaughtExceptionHandlerSkipAddressCount;
         
         i < UncaughtExceptionHandlerSkipAddressCount +
         
         UncaughtExceptionHandlerReportAddressCount;
         
         i++)
        
    {
        
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
        
    }
    
    free(strs);
    
    return backtrace;
    
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
    {
        dismissed = YES;
    }
}

- (void)handleException:(NSException *)exception

{
    //保存应用上次退出状态以及相关信息
    [FileManager setUserDefaults:[NSNumber numberWithInteger:ExitAppStatusException] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    NSString *versionCode = [WSEnvrionment getAppSystemVersion];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
    
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *stack_trace = [exception callStackSymbols];
    NSDictionary *userInfo = [exception userInfo];
    
    NSString *crashLog = [NSString stringWithFormat:@"name:%@\nreason:%@\ncallStackSymbols:\n%@\nuserInfo:\n%@\n",name,reason, [stack_trace componentsJoinedByString:@"\n"],userInfo];
    
    [[WCLogManager sharedInstance] addCrashLog:crashLog];
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
    
}

@end


void MySignalHandler(int signal)

{
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    //signal 不作为crash日志记录到crash文件里边，只打印到log文件中 wh 14.5.29
    LogCError(@"Singal hanndled -->>\n%@",userInfo);
//    NSException *excepitonObject = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:
//                                    [NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.\n", nil), signal] userInfo:userInfo];
//    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject: excepitonObject waitUntilDone:YES];
    
}

void ExceptionHandler(NSException *exception)
{
    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                              withObject:exception
                                                           waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler()

{
    
    NSSetUncaughtExceptionHandler(&ExceptionHandler);
    
    signal(SIGABRT, MySignalHandler);
    signal(SIGILL, MySignalHandler);
    signal(SIGSEGV, MySignalHandler);
    signal(SIGFPE, MySignalHandler);
    signal(SIGBUS, MySignalHandler);
    signal(SIGPIPE, MySignalHandler);
    
}
