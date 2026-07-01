//
//  WSTextValidate.m
//  WinSFA
//
//  Created by winchannel on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
#import "WSWidget.h"


@implementation WSValidate

-(id)init{
    
    self = [super init];
    if (self) {
        
        
        return self;
    }
    return nil;
    
}

-(BOOL)isRequire:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    if ([[buildInfo getISRequire] isEqualToString:@"1"]) {
        
        return YES;
        
    }
    return NO;
}



-(WSMessageObject *)getMessageObject:(NSString *)message AndTitle:(NSString *)title
                          andButtons:(NSMutableArray *)buttons andDelegate:(id)delegate
                           messageId:(NSString *)messageId
                         messageType:(NSInteger)messageType {
    WSMessageObject  *messageobject =[[WSMessageObject alloc] init];
    [messageobject setMessageId:messageId];
    [messageobject setMessageType:messageType];
    [messageobject setDisplayTitle:title];
    [messageobject setDisplayMessage:message];
    [messageobject setButtons:buttons];
    [messageobject setMessageDelegate:delegate];
    return messageobject;
}



@end
