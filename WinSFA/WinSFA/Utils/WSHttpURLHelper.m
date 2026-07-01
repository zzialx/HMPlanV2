//
//  WSHttpURLHelper.m
//  WinSFA
//
//  Created by xiajl on 15/1/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSHttpURLHelper.h"
#import "WSServerIPList.h"
#import "WSEnvrionment.h"
#import "WSRequestHelper.h"
#import "UIDevice+IdentifierAddition.h"
#import "WSJSONBuilder.h"
#import "JFDEntryObject.h"

@implementation WSHttpURLHelper

+ (NSString *)getCompleteURL:(NSString *)partOfURL {
    
    NSString *serverString = [WSHttpURLHelper getRootConfigWebAddress];
    
    if ([JFDEntryObject getInstance].debugWebServer) {
        serverString = [JFDEntryObject getInstance].debugWebServer;
    }
    if (![WSEnvrionment getParamInLoginData] && serverString && [serverString hasPrefix:@"http://"]) {
        if (![serverString hasSuffix:@"/"]) {
            serverString = [serverString stringByAppendingFormat:@"/"];
        }
        
    } else {
        serverString = [WSHttpURLHelper getConfigFileServerIP];
    }
    
    return [serverString stringByAppendingString:partOfURL];
        
}


+ (NSString *)getCompleteURLByServerUrl:(NSString *)serverUrl partOfURL:(NSString *)partOfURL {
    if (![serverUrl hasSuffix:@"/"]) {
        serverUrl = [serverUrl stringByAppendingFormat:@"/"];
    }
    return [serverUrl stringByAppendingString:partOfURL];
}


+(NSString *)getRootConfigURL{
    NSString *serverString = [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName];
    return [serverString stringByAppendingString:GET_ROOTCONFIG];
}

+ (NSString *)getImageCompleteURL:(NSString *)partOfURL
{
    if([[WSRequestHelper shareInstance] isHttpString:partOfURL])
    {
        return partOfURL;
    }else if (![WSEnvrionment getUseAliyun]) {
        return [WSHttpURLHelper getImgCompleteURLWithPartOfURL:partOfURL];
    } else if (![[WSRequestHelper shareInstance] isUseAliyunByString:partOfURL]) {
        return [WSHttpURLHelper getImgCompleteURLWithPartOfURL:partOfURL];
    } else {
        return partOfURL;
    }
}

+ (NSString *)getImgCompleteURLWithPartOfURL:(NSString *)partOfURL {
    NSString *serverUrl = [WSHttpURLHelper getLoginDataServerUrl];
    
    if (!serverUrl || serverUrl.length == 0) {
        serverUrl = [WSHttpURLHelper getConfigFileServerIP];
    }
    
    NSString *imagePath = partOfURL;
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    
    if ([serverUrl hasSuffix:@"/"] && [imagePath hasPrefix:@"/"]) {
        imagePath = [imagePath substringFromIndex:1];
    }
    
    NSString *imageURL = [NSString stringWithFormat:@"%@%@", serverUrl, imagePath];
    imageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return imageURL;
}

// MSTD-6717 SAAS 客户端地址由服务器返回
+ (NSString *)getConfigFileServerIP
{
    NSString *serverString;
    NSString *saasUrl = [WSEnvrionment getSaasUrl];
    if (!saasUrl || [saasUrl length] == 0) {
        serverString = [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName];
    } else {
        serverString = [WSHttpURLHelper getSaasWebAddres];
    }
    return serverString;
}

+ (NSString *)getRootConfigWebAddress
{
    NSUserDefaults *addressDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverString = [addressDefaults  objectForKey:WEB_ADDRESS];
    return [serverString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)getLoginDataServerUrl
{
    WSServerIPList *svip = [WSAppData getObjectbyKey:SERVERURL];
    WSServerIPController *serverIP =[svip.serverIPArray firstObject];
    NSString *serverUrl = [serverIP ServerIPString];
    return serverUrl;
}

+ (NSString *)getSaasWebAddres
{
    NSUserDefaults *addressDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverString = [addressDefaults  objectForKey:SAAS_WEB_ADDRESS];
    return [serverString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)getNeedsSignUrl:(NSString *)urlString {
    
    NSString *signKey = [WSAppData getObjectbyKey:APPDATA_SIGNKEY];
    if (!signKey || [signKey length] == 0) {
        return urlString;
    }
    
    NSMutableArray *signParamArray = [NSMutableArray arrayWithCapacity:5];
    NSString *imei = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [signParamArray addObject:[NSString stringWithFormat:@"imei=%@", imei]];
    
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    [signParamArray addObject:[NSString stringWithFormat:@"appid=%@", appId]];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_BEGIN_LOGIN];
    [signParamArray addObject:[NSString stringWithFormat:@"uid=%@", userName]];
    
    NSString *timeStamp = [WSCurrentTime getTimeMillisStringForDevice];
    [signParamArray addObject:[NSString stringWithFormat:@"timestamp=%@", timeStamp]];
    
    NSString *uuid = [WSJSONBuilder gen_uuid];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [signParamArray addObject:[NSString stringWithFormat:@"nonce=%@", uuid]];
    
    NSString *urlJoinString;
    NSArray *paramArray;
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        
        NSString *paramString = [urlString substringFromIndex:range.location + 1];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray: [paramString componentsSeparatedByString:@"&"]];
        paramArray = [tempArray arrayByAddingObjectsFromArray:signParamArray];
        urlJoinString = @"&";
    }
    else {
        paramArray = signParamArray;
        urlJoinString = @"?";
    }
    
    NSArray *sortArray = [paramArray sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        NSComparisonResult result = [str1 compare:str2 options:NSNumericSearch];
        return result;
    }];
    
    NSString *sortString = [sortArray componentsJoinedByString:@""];
    NSString *toSignString = [sortString stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    toSignString = [NSString stringWithFormat:@"%@%@%@", signKey, toSignString, signKey];
    LogInfo(@"to sign:%@", toSignString);
    
    NSString *sign = [toSignString md5];
    [signParamArray addObject:[NSString stringWithFormat:@"winc_sign=%@", [sign uppercaseString]]];
    
    NSString *newParamString = [signParamArray componentsJoinedByString:@"&"];
    urlString = [urlString stringByAppendingFormat:@"%@%@", urlJoinString, newParamString];
    return urlString;
}

@end
