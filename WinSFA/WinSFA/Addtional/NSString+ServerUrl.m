//
//  NSString+ServerUrl.m
//  WinSFA
//
//  Created by mac on 16/12/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "NSString+ServerUrl.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "WSRequestHelper.h"

@implementation NSString (ServerUrl)
- (NSString *)buildupUrl
{
    BOOL isUseAliyun = [[WSRequestHelper shareInstance] isUseAliyunByString:self];
    if (!isUseAliyun) {
        NSString *url = nil;
        WSServerIPList *svip = [WSAppData getObjectbyKey:SERVERURL];
        if (svip && svip.serverIPArray && [svip.serverIPArray count]) {
            WSServerIPController *serverIP = [svip.serverIPArray objectAtIndex:0];
            NSString *tmpStr = [self stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
            NSString *urlString = [tmpStr stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            NSString *s1 = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)urlString, NULL,(CFStringRef) @"!*'();:@&=+$,%#[]", kCFStringEncodingUTF8));
            url = [[NSString alloc] initWithFormat:@"%@%@", serverIP.ServerIPString, s1];
            //MMSH-3607
            // SFA玛氏中国MWC- 【IOS:拜访】账号cszlyd01,1111,门店10206154，完美门店成功图像不显示大图
            //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        }
        return url;
    } else {
        return self;
    }
}
@end
