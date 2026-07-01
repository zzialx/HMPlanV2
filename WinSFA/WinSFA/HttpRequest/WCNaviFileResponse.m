//
//  WCNaviFileResponse.m
//  WinSFA
//
//  Created by yang on 13-6-18.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WCNaviFileResponse.h"
#import <WCDataPacker.h>
#import <JSONKit.h>

@implementation WCNaviFileResponse

-(void)parseResponseData
{
    NSData *responseData = [[WCDataPacker sharedInstance] unpackForPostBody:self.resopnseData];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    self.jsonResponse = [responseString objectFromJSONString];
}

@end
