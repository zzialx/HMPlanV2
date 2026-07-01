//
//  WSCookieHelper.m
//  WinSFA
//
//  Created by Stephanie on 16/5/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCookieHelper.h"

@implementation WSCookieHelper


+ (void)setCookies:(NSArray *)cookies forURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    for (NSHTTPCookie *cookie in cookies) {
        
        NSMutableDictionary *cookDic = [NSMutableDictionary dictionary];
        
        if ([cookie.domain isEqualToString:url.host]) {
            break;
        }
        
        if (url.host) {
            [cookDic setObject:url.host forKey:NSHTTPCookieDomain];
        }
        
        if (url.path) {
            [cookDic setObject:url.path forKey:NSHTTPCookiePath];
        }
        
        if (cookie.name) {
            [cookDic setObject:cookie.name forKey:NSHTTPCookieName];
        }
        if (cookie.value) {
            [cookDic setObject:cookie.value forKey:NSHTTPCookieValue];
        }
        [cookDic setObject:[NSNumber numberWithUnsignedInteger:cookie.version] forKey:NSHTTPCookieVersion];
        if (cookie.expiresDate) {
            [cookDic setObject:cookie.expiresDate forKey:NSHTTPCookieExpires];
        }
        [cookDic setObject:[NSNumber numberWithBool:cookie.sessionOnly] forKey:NSHTTPCookieDiscard];
        
        
        [cookDic setObject:[NSNumber numberWithBool:cookie.isSecure] forKey:NSHTTPCookieSecure];
        
        
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookDic];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
    }
}

+ (void)setCookieByName:(NSString *)name value:(NSString *)value url:(NSURL *)url
{
    
    NSMutableDictionary *cookDic = [NSMutableDictionary dictionary];
    
    if (url.host) {
        [cookDic setObject:url.host forKey:NSHTTPCookieDomain];
    }
    if (url.path) {
        [cookDic setObject:url.path forKey:NSHTTPCookiePath];
    }
    
    //    [cookDic setObject:@"/" forKey:NSHTTPCookiePath];
    
    [cookDic setObject:name forKey:NSHTTPCookieName];
    
    [cookDic setObject:value forKey:NSHTTPCookieValue];
    
    NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookDic];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
}

+ (void)removeCookieForName:(NSString *)name
{
    [WSCookieHelper removeCookieForName:name url:nil];
}

+ (void)removeCookieForName:(NSString *)name url:(NSURL *)url
{
    NSArray *cookies = nil;
    
    if (url) {
        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    }else {
        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    }
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

+ (NSString *)getCookieValueForName:(NSString *)name url:(NSURL *)url
{
    NSArray *cookieArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    
    NSString *value = nil;
    
    for (NSHTTPCookie *cookie in cookieArray) {
        if ([cookie.name isEqualToString:name]) {
            value = cookie.value;
            break;
        }
    }
    
    return value;
}

@end
