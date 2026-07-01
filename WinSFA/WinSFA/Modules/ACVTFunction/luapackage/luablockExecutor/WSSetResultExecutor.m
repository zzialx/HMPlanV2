//
//  WSSetResultExecutor.m
//  WinSFA
//
//  Created by lishuli on 2018/12/21.
//  Copyright © 2018 WinChannel. All rights reserved.
//

#import "WSSetResultExecutor.h"
#import "WSInterAction.h"

@implementation WSSetResultExecutor

+ (instancetype)sharedInstance
{
    static WSSetResultExecutor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    __weak __typeof(self) wself = self;

    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj, ...) {
        __strong __typeof(wself) sself = wself;

        if ([firstObj isKindOfClass:[NSString class]] && [firstObj isEqualToString:@"setResult"]) {
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            if ([secondObj isKindOfClass:[NSString class]]) {
                
                WSInterAction  *interaction =[[WSInterAction alloc] init];
                [interaction setExecute_result:secondObj];
                
                if ([sself.delegate respondsToSelector:@selector(executeInterAction:)]) {
                        [sself.delegate executeInterAction:interaction];
                    return @"";
                }
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@",secondObj];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            va_end(argsList);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers error:&err];
            [WSSetResultExecutor sharedInstance].result = [dic objectForKey:@"maxCount"];
        }
        return @"";
    };
    return [paramExpanedBlock copy];
}

@end
