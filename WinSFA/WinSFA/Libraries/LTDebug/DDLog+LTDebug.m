//
//  DDLog+LTDebug.m
//  LTDebug
//
//  Created by Alicia on 2017/3/4.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "DDLog+LTDebug.h"

#import "objc/runtime.h"
#import "LTDebugMacro.h"
#import "LTDDLogModel.h"
#import "LTDDLog.h"
#import "WSEnvrionment.h"

@implementation DDLog (LTDebug)


+ (BOOL)isLogOn {
    return [WSEnvrionment getUseDebugTool];
}

+ (void)load {
    if (![self isLogOn]) {
        return;
    }
    
    LTDDLog *log = [[LTDDLog alloc] init];
    [log clearLog];
 
    lt_ddlog_swizzleMethod([self class],
                           @selector(log:
                                     message:
                                     level:
                                     flag:
                                     context:
                                     file:
                                     function:
                                     line:
                                     tag:),
                           @selector(swizzle_log:
                                     message:
                                     level:
                                     flag:
                                     context:
                                     file:
                                     function:
                                     line:
                                     tag:));
}

void lt_ddlog_swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzle_log:(BOOL)asynchronous
            message:(NSString *)message
              level:(DDLogLevel)level
               flag:(DDLogFlag)flag
            context:(NSInteger)context
               file:(const char *)file
           function:(const char *)function
               line:(NSUInteger)line
                tag:(id)tag {
    
    
    NSString *func = [NSString stringWithFormat:@"%s", function];
    LTDDLogModel *logModel = [[LTDDLogModel alloc] initWithLogFlag:flag message:message function:func];
    LTDDLog *log = [[LTDDLog alloc] init];
    [log addLogModel:logModel];
    
   
    [self swizzle_log:asynchronous
              message:message
                level:level
                 flag:flag
              context:context
                 file:file
             function:function
                 line:line
                  tag:tag];
}

@end
