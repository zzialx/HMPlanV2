//
//  I_M_Display.h
//  WinSFA
//
//  Created by winchannel on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_M_Display_h
#define WinSFA_I_M_Display_h

@protocol I_M_Display <NSObject>

-(NSString *)getMessageId;  //消息的编号

-(NSString *)getDisplayTitle;  //消息的显示title

-(NSString *)getDisplayMessage; //消息内容

-(NSMutableArray *)getDisplayButtons;  //消息操作按钮

-(UIImage *)getProductIcon;  //消息显示的图标

-(NSInteger)getMessageType;   //消息类型，根据不同的消息类型提供不同的消息呈现界面

-(id)getCurrentMessageDelegate; //获得当前的消息代理

@end

#endif
