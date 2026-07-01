//
//  WSMeetingApplicantInfoExecutor.m
//  WinSFA
//
//  Created by heju on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMeetingApplicantInfoExecutor.h"
#import "WinSFA.h"
#import "WSLuaScriptEnter.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"

static NSString *const CURRENT_VALUE = @"currentValue";
static NSString *const USER_ID = @"userId";
static NSString *const USER_NAME = @"userName";
static NSString *const STORE_ID = @"storeId";
static NSString *const STORE_NAME = @"storeName";
static NSString *const UPLOAD_TIME = @"uploadTime";

@interface WSMeetingApplicantInfoExecutor ()

@end

@implementation WSMeetingApplicantInfoExecutor

- (id)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        __strong __typeof(wself) sself = wself;
        NSLog(@"%@", firstObj);
        if (firstObj) {
            NSString *qstNameString = [NSString stringWithFormat:@"%@" ,firstObj];
            
            NSObject<I_Lua_Target_Operator>  * tempoperator =  [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstNameString];
            
            va_list argslist;
            va_start(argslist, firstObj);
            id secondObj = va_arg(argslist, id);
            NSString *paramString = [NSString stringWithFormat:@"%@",secondObj];
            va_end(argslist);
            
            // 根据paramString 值重新加载当前widget显示值
            NSString *qstValue = [self againMeetingInfoWith:paramString];
            
            NSObject *object = [tempoperator getValuePresentationForCurrentObject];
            
            if (!object || ([object isKindOfClass:[NSString class]]  && [(NSString *)object length] == 0)) {
                [ tempoperator setValueForCurrentObject:qstValue];
            } 
        }
        return @"1";
    };
    
    return [paramExpanedBlock copy];
    
}

- (NSString *)doExecute:(WSLuaScriptEnter *)executerEnter {
    
    return [executerEnter runMeetingApplicantInfo];
    
}

/*
 根据luaParam获取不同的值
 */
- (NSString *)againMeetingInfoWith:(NSString *)luaParam {
    
    WSBaseModel *baseModel = [[WSDataSourceManager sharedInstance] currentActiveModel];
    NSString *infoOfMeeting = nil;
    if (luaParam) {
        if ([luaParam isEqualToString:CURRENT_VALUE]) {
            //  to  do something
        } else if ([luaParam isEqualToString:USER_ID]) {
            infoOfMeeting = [WSAppData getObjectbyKey:APPDATA_EMPID];
        } else if ([luaParam isEqualToString:USER_NAME]) {
            infoOfMeeting = [WSAppData getObjectbyKey:APPDATA_EMPNAME];
        } else if ([luaParam isEqualToString:STORE_ID]) {
            infoOfMeeting = [[baseModel currentStore] Id];
        } else if ([luaParam isEqualToString:STORE_NAME]){
            infoOfMeeting = [[baseModel currentStore] name];
            
        } else if ([luaParam isEqualToString:UPLOAD_TIME]) {
            // 是否是此时间需要考证
            infoOfMeeting = [WSCurrentTime getDateTime];
        }
    }
    return infoOfMeeting;
}

@end
