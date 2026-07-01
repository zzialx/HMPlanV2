//
//  WSWelcomeDataService.m
//  WinSFA
//
//  Created by Alicia on 2017/10/30.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWelcomeDataService.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSFuncsBeanArray.h"


#define kWelcomeFuncsFV         @"FV_welcome_page"
#define kLastWelcomeUrl         @"welcomeUrl"       //  当前已下载的图片地址，用于判断是否需要更新图片

@implementation WSWelcomeDataService

static WSWelcomeDataService *welcomeDataService = nil;

+ (WSWelcomeDataService *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        welcomeDataService = [[WSWelcomeDataService alloc] init];
    });
    return welcomeDataService;
}

#pragma mark - Public Method

- (WSFuncsBean *)getWelcomeFuncsBean {
    WSFuncsBean *welcomeFuncsBean = nil;
    
    NSArray *loginRedirectFcS = [WSAppData getObjectbyKey:APPDATA_LOGIN_REDIRECT_FC];
    if ([loginRedirectFcS count] > 0) {
        
        WSFuncsBeanArray *fbArray = [WSAppData getObjectbyKey:FUNCS];
        for (NSString *fc in loginRedirectFcS) {
            WSFuncsBean *funcsBean = [fbArray getHideFuncsBeanWithFC:fc];
            if (funcsBean.fc.length > 0) {
                welcomeFuncsBean = funcsBean;
                break;
            }
        }
    }
    return welcomeFuncsBean;
}

- (NSString *)getWelcomeUrl {
    WSFuncsBean *funcsBean = [self getWelcomeFuncsBean];
    if (funcsBean && [funcsBean.fv isEqualToString:kWelcomeFuncsFV]) {
        return funcsBean.filter;
    } else {
        return nil;
    }
}

- (BOOL)hasCacheFileWithUrl:(NSString *)url {
    if (!url || [url length] == 0) {
        return NO;
    }
    
    NSString *lastWelcomeUrlString = [[NSUserDefaults standardUserDefaults] objectForKey:kLastWelcomeUrl];
    if ([lastWelcomeUrlString isEqualToString:url]) {
        return YES;
    }
    
    return NO;
}

// MSTD-6659 紧急上线，目前只需要做图片的处理
- (void)downloadFileWithUrl:(NSString *)url completeBlock:(WSWelcomeCompleteBlock)completeBlock {

    [[WSRequestHelper shareInstance] downloadImageWithUrl:url progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
        BOOL isSuccess = YES;
        if (error) {
            isSuccess = NO;
            LogError(@"WSWelcomeManager error is %@",error);
        }
        if (image) {
            // save url
            [[NSUserDefaults standardUserDefaults] setObject:url forKey:kLastWelcomeUrl];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (completeBlock) {
            completeBlock (isSuccess);
        }
    }];
}


@end
