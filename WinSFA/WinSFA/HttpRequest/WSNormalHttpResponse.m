//
//  WSNormalHttpResponse.m
//  WinSFA
//
//  Created by xiajl on 15/1/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSNormalHttpResponse.h"
//#import "WSStatisticsManager.h"
#import "WCDataPacker2.h"
#import "DecompressUtil.h"

@implementation WSNormalHttpResponse

-(void)parseResponseData
{
    NSString *tmpResponse = nil;
    
    @autoreleasepool {
        
        BOOL isLogin = NO;
        NSString *unzipBeginTime;
        if ([self.requestIdentifer isEqualToString:LOGIN_NOTIFY]) {
            isLogin = YES;
//            [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_LOGIN_DATA_SIZE
//                                                                    startTime:nil
//                                                                      endTime:nil
//                                                                   eventValue:[[NSNumber numberWithUnsignedInteger:self.resopnseData.length] stringValue]
//                                                                        genId:[WSStatisticsManager getGenId]];
            unzipBeginTime = [WSCurrentTime getTimeMillisStringForDevice];
            
        }
        
        NSData *responseData = [DecompressUtil uncompressZippedData:self.resopnseData];
        
        if (isLogin) {
//            [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_LOGIN_DATA_SIZE_UNZIP
//                                                                    startTime:nil
//                                                                      endTime:nil
//                                                                   eventValue:[[NSNumber numberWithUnsignedInteger:responseData.length] stringValue]
//                                                                        genId:[WSStatisticsManager getGenId]];
//
//            [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_UNZIP
//                                                                    startTime:unzipBeginTime
//                                                                      endTime:[WSCurrentTime getTimeMillisStringForDevice]
//                                                                   eventValue:nil
//                                                                        genId:[WSStatisticsManager getGenId]];
            
        }
        
        if (responseData == nil || responseData.length == 0) {
            
            tmpResponse = [[NSString alloc]
                           initWithData:self.resopnseData
                           encoding:NSUTF8StringEncoding];
        }else{
            
            tmpResponse = [[NSString alloc]
                           initWithData:responseData
                           encoding:NSUTF8StringEncoding];
        }
    }
    
    if (tmpResponse && [tmpResponse length] > 0) {
        NSError *error;
        
        //SFA-25719 特别标注
        //下发的数据那存在number类型 eg:{\"id0\":9.0,\"id1\":9.1,\"id2\":9.2}类型数据 ios无论是jsonKit还是原生态NSJSONSerialization都会存在数据问题 eg:9.2变为9.199999999999999
        //现在解决方案 是要求服务器下发的数据 为{\"id0\":\"9.0\",\"id1\":\"9.1\",\"id2\":\"9.2\"}
        self.jsonResponse = [tmpResponse mutableObjectFromJSONStringWithParseOptions:JKParseOptionStrict|JKParseOptionLooseUnicode error:&error];
        
        if (error) {
            LogError(@"网络请求返回json解析错误：%@", error);
        }
    }
}

-(void)parseResponseDataWithNewEncryptRules
{
    NSString *tmpResponse = nil;
    
    WCDataPacker2 *packer02 = [WCDataPacker2 sharedInstance];

    @autoreleasepool {
        
        BOOL isLogin = NO;
        NSString *unzipBeginTime;
        
        if ([self.requestIdentifer isEqualToString:LOGIN_NOTIFY]) {
            isLogin = YES;
//            [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_LOGIN_DATA_SIZE
//                                                                    startTime:nil
//                                                                      endTime:nil
//                                                                   eventValue:[[NSNumber numberWithUnsignedInteger:self.resopnseData.length] stringValue]
//                                                                        genId:[WSStatisticsManager getGenId]];
            unzipBeginTime = [WSCurrentTime getTimeMillisStringForDevice];
            
        }
        
        NSData *responseData = nil;
        if ([self.requestIdentifer isEqualToString:CHANGE_NOTIFY]) {
            responseData = [packer02 unpackForNormalResponseData:self.resopnseData isTowPartKey:NO];
        }else {
            responseData = [packer02 unpackForNormalResponseData:self.resopnseData];
        }
        
        if (isLogin) {
//            [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_LOGIN_DATA_SIZE_UNZIP
//                                                                    startTime:nil
//                                                                      endTime:nil
//                                                                   eventValue:[[NSNumber numberWithUnsignedInteger:responseData.length] stringValue]
//                                                                        genId:[WSStatisticsManager getGenId]];
//            
//            [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_UNZIP
//                                                                    startTime:unzipBeginTime
//                                                                      endTime:[WSCurrentTime getTimeMillisStringForDevice]
//                                                                   eventValue:nil
//                                                                        genId:[WSStatisticsManager getGenId]];
            
        }
        
        if (responseData == nil || responseData.length == 0) {
            
            tmpResponse = [[NSString alloc]
                           initWithData:self.resopnseData
                           encoding:NSUTF8StringEncoding];
        }else{
            
            tmpResponse = [[NSString alloc]
                           initWithData:responseData
                           encoding:NSUTF8StringEncoding];
        }
    }
    
    if (tmpResponse && [tmpResponse length] > 0) {
        NSError *error;
        self.jsonResponse = [tmpResponse mutableObjectFromJSONStringWithParseOptions:JKParseOptionStrict|JKParseOptionLooseUnicode error:&error];
        
        if ([self.requestIdentifer isEqualToString:GETROOTCONFIG_NOTIFY]) {
            NSString *secondPartKeyCodeStr = [self.jsonResponse objectForKey:@"sfa"];
            [packer02 setInitHttpCode2:secondPartKeyCodeStr];
        }
        
        if (error) {
            LogError(@"网络请求返回json解析错误：%@", error);
        }
    }
}

@end
