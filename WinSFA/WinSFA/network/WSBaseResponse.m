//
//  WSBaseResponse.m
//  WinSFA
//
//  Created by xiaotang.wang on 9/23/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSBaseResponse.h"
#import "WCError.h"

@implementation WSBaseResponse

@synthesize iError = _iError;

@synthesize iJsonResponse = _iJsonResponse;

@synthesize iResopnseData = _iResopnseData;

- (id)initWithResponseData:(NSData *)aData
{
    self = [super init];
    if (self) {
        _iResopnseData = aData;
        [self parseResponseData];
        [self parseJsonData];
    }
    return self;
}

- (id)initWithError:(NSError *)aError
{
    self = [super init];
    if (self) {
        _iError = [WCError errorWithNSError:aError];
    }
    return self;
}

- (void)parseResponseData
{
    //暂不考虑压缩和编码问题默认编码为:NSUTF8StringEncoding
    if (self.iResopnseData != nil) {
        NSString *str = [[NSString alloc] initWithData:self.iResopnseData encoding:NSUTF8StringEncoding];
        self.iJsonResponse = [str objectFromJSONString];
    }
}

- (void)parseJsonData
{
    //检测业务日期 CheckBizData（待定）
    //检测是否退出 decideExitApplication（待定）
}



@end
