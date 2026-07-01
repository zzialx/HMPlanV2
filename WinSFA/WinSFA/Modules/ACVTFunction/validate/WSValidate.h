//
//  WSTextValidate.h
//  WinSFA
//
//  Created by winchannel on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSMessageObject;

@interface WSValidate : NSObject

-(BOOL)isRequire:(NSObject<I_W_BuildInfo> *)buildInfo;

-(WSMessageObject *)getMessageObject:(NSString *)message AndTitle:(NSString *)title
                          andButtons:(NSMutableArray *)buttons andDelegate:(id)delegate
                           messageId:(NSString *)messageId
                         messageType:(NSInteger)messageType;

@end
