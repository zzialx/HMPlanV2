//
//  WSMjetLoginManager.m
//  WinSFA
//
//  Created by Stephanie on 16/5/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMjetLoginManager.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "GTMBase64.h"
#import "WSRequestHelper.h"
#import "WSCookieHelper.h"


static WSMjetLoginManager *_instance;

@interface WSMjetLoginManager ()

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *currentSSOSessionURL;

@property (nonatomic, strong) NSArray *currentSessionArray;

@property (nonatomic, strong) NSString *currentSession;

@end

@implementation WSMjetLoginManager

+ (WSMjetLoginManager *)sharedInstance
{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[WSMjetLoginManager alloc] init];
        });
    }
    
    return _instance;
}

+ (BOOL)isNeedMejtLogin
{
    NSString *isNeedMjetLogin = [WSPlistHelper valueForKey:kSSO_LOGIN withPlistName:kConfilgFileName];
    if ([isNeedMjetLogin isEqualToString:@"1"]) {
        return YES;
    }else {
        return NO;
    }

}

+ (BOOL)isNeedGetSSOSession
{
    NSString *ssoSession = [WSPlistHelper valueForKey:kSSO_SESSION withPlistName:kConfilgFileName];
    if ([ssoSession length] > 0) {
        return YES;
    }else {
        return NO;
    }

}


- (void)setUpUsername:(NSString *)username password:(NSString *)password
{
    
}

- (void)mjetLogin
{
    
}

- (BOOL)mjetLogout
{
    return YES;
}

- (void)getSSOSessionForUrl:(NSString *)urlString
{

}

- (void)getSSOSessionWithSessoionArray:(NSArray *)sessionArray
{
    
}

- (void)startSSOSessionGetRootConfig
{

}

- (void)getSSOSessionRootConfigFinish:(id)sender
{

}


@end
