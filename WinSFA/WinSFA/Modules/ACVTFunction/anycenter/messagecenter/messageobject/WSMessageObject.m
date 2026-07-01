//
//  WSMessageObject.m
//  WinSFA
//
//  Created by winchannel on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMessageObject.h"
#import "I_M_Display.h"


@implementation WSMessageObject

@synthesize  messageId;
@synthesize displayTitle;
@synthesize displayMessage;
@synthesize buttons;
@synthesize productIcon;
@synthesize messageType;
@synthesize messageDelegate;

//消息的编号
-(NSString *)getMessageId{
    
    return messageId;
    
}
//消息的显示title
-(NSString *)getDisplayTitle{
    
    return displayTitle;
}
 //消息内容
-(NSString *)getDisplayMessage{
    
    return displayMessage;
}
//消息操作按钮
-(NSMutableArray *)getDisplayButtons{
    
    return buttons;
}
 //消息显示的图标
-(UIImage *)getProductIcon{
    
    return productIcon;
}
//消息类型，根据不同的消息类型提供不同的消息呈现界面
-(NSInteger)getMessageType{
    
    return messageType;
}

//获得当前的消息代理
-(id)getCurrentMessageDelegate{
    
    return messageDelegate;
}
@end
