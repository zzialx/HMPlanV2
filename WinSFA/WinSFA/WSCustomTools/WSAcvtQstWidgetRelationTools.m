//
//  WSAcvtQstWidgetRelationTools.m
//  WinSFA
//
//  Created by HZH on 2018/5/15.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtQstWidgetRelationTools.h"
#import "WSRequestHelper.h"

#define kRealtimeDataNotify     @"RealtimeDataNotify"

typedef void(^realtimeRequestFinishCallback)(id resultDic);

@interface WSAcvtQstWidgetRelationTools ()

@property (nonatomic, copy) realtimeRequestFinishCallback realtimeRequestFinishCallbackBlock;  // 回调
@property (nonatomic, copy) NSString* notifyName;  // 回调


@end

@implementation WSAcvtQstWidgetRelationTools

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

+ (instancetype)sharedManager
{
    static WSAcvtQstWidgetRelationTools *acvtQstWidgetRelationTools;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        acvtQstWidgetRelationTools = [[WSAcvtQstWidgetRelationTools alloc] init];
    });
    
    return acvtQstWidgetRelationTools;
}

- (void)getRealtimeDataWithParamDic:(NSDictionary *)paramDic andRealtimeRequestFinishCallback:(void (^)(id resultDic))callback
{
    
    if (!paramDic) {
        return ;
    }
    
    _realtimeRequestFinishCallbackBlock = callback;
    
    self.notifyName = [paramDic objectForKey:@"objId"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRealtimeDataFinish:) name:[paramDic objectForKey:@"objId"] object:nil];
    [[WSRequestHelper shareInstance] postRequestData:paramDic notifyName:[paramDic objectForKey:@"objId"]];

}

// 服务器搜索返回数据
- (void)getRealtimeDataFinish:(id)sender {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.notifyName object:nil];
    // 解析数据
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    
    if ([flag isEqualToString:@"0"]) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        return;
    }
    
    _realtimeRequestFinishCallbackBlock(dic);
}

@end
