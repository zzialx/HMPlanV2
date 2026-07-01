//
//  WSHandleAcvtMethodExecutor.m
//  WinSFA
//
//  Created by heju on 2016/12/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSHandleAcvtMethodExecutor.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSAcvtViewController.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
@implementation WSHandleAcvtMethodExecutor

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock
{
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...)
    {
        NSString *methodStr = [NSString stringWithFormat:@"%@" ,firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        NSString *paramStr = [NSString stringWithFormat:@"%@",secondObj];
        
        if([methodStr length] > 0 && [methodStr isEqualToString:@"UPDATE_CALENDAR_DATA"])
        {
            LogInfo(@"WSHandleAcvtMethodExecutor,methodStr:%@,paramStr:%@ ", methodStr,paramStr);
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            [model.ownAcvtViewController updateCalendarData:paramStr];
        }
        else if([methodStr length] > 0 && [methodStr isEqualToString:@"UPDATE_GENID"])
        {
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            [model.ownAcvtViewController updateGenidData:paramStr];
        }

        return @"";
    };
    return [paramExpanedBlock copy];
}

@end
