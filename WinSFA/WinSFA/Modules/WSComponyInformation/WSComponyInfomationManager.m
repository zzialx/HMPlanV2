//
//  WSComponyInfomationManager.m
//  WinSFA
//
//  Created by zzialx on 2024/1/23.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import "WSComponyInfomationManager.h"
#import "WSBaseMsgTable.h"
#import "WSJSONBuilder.h"
#import "GetMD5byStr.h"
#import "WSRequestTools.h"
#import "WSRequestHelper.h"
#import "WSFuncsBeanArray.h"

static WSComponyInfomationManager *instance;


@implementation WSComponyInfomationManager

#pragma mark - 单例方法
+ (WSComponyInfomationManager *)sharedInstance{
    
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSComponyInfomationManager alloc] init];
        });
    }
    return instance;
}
#pragma mark - # 标记消息阅读状态
+ (void)markAsReadedByMsg:(NSString *)msgId {
    if (!msgId) {
        LogError(@"消息id为空");
        return;
    }
    //更新阅读状态
    [[WSBaseMsgTable sharedTable] updateWithNames:@[@"isread"] values:@[@"1"] whereName:@[@"_id"] whereValue:@[msgId]];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@", msgId,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];

    NSNumber *number = [dic objectForKey:key];
    if (number == nil || ![number boolValue]) {
        [self sendReadedMessageRequestByMsg:msgId];
    }
    
    NSNumber *value = [NSNumber numberWithBool:YES];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if (value) {
        [dicInfo setObject:value forKey:key];
    }
    
    if (dicInfo) {
        [user setObject:dicInfo forKey:kWSMessageDomainName];
    }
    
    [user synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

+ (void)sendReadedMessageRequestByMsg:(NSString *)msgId {

    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *md5 = [NSString md5:[NSString stringWithFormat:@"%@%@%@",empId,bizDate,msgId]];
    
    NSString  *strData = [WSJSONBuilder  buildSendRedMessageWithMsgId:msgId andNotifyName:notifyID andMD5:md5];
    // 先插入数据库
    [self insertUploadData:strData URL:URL_UPLOAD MD5:md5 IsPhoto:NO NotifyName:notifyID];
    
    // 再上传数据，后更新upload_flag
    WSRequestHelper *uploadHandler = [WSRequestHelper shareInstance];
    [uploadHandler sendReadedMessageRequestWithMsgId:msgId andNotifyName:notifyID andMD5:md5];
}
#pragma mark - insert off line table
+ (void) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    if (!aNotifyName) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为空");
        return;
    }
    if ([aNotifyName isKindOfClass:[NSNull class]]) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为NULL");
        return;
    }
    
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    //person
    [l_Values addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
    //date
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:aPostDate];
    //url
    [l_Values addObject:aUrl];
    //md5
    [l_Values addObject:aMd5];
    //isphoto
    if(aIsPhoto)
    {
        [l_Values addObject:@"1"];
        
    }else
        [l_Values addObject:@"0"];
    
    [l_Values addObject:aNotifyName];
    
    // 为保存向前兼容，不修改其它调用此方法的类，将之前使用此方法保存的数据都定为 D 类型
    [l_Values addObject:@"D"];
    
    //图片类型的存储图片路径，其他类型不需要使用，保持兼容，存个null
    [l_Values addObject:[NSNull null]];
    
    [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
}

#pragma mark - # 是否跳转隐私协议
+ (BOOL)isShouldPushRedirectFC{
    
    NSArray *loginRedirectFcS = [WSAppData getObjectbyKey:APPDATA_LOGIN_REDIRECT_FC];
    if (loginRedirectFcS.count == 0) {
        return NO;
    }
    WSFuncsBeanArray *fbArray = [WSAppData getObjectbyKey:FUNCS];
    for (NSString *fc in loginRedirectFcS) {
        WSFuncsBean *funcsBean = [fbArray getAllFuncsBeanWithFC:fc];
        if (funcsBean.fc.length == 0) {
            return NO;
        }
    }
    return YES;
}
@end
