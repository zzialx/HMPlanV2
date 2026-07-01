//
//  I_W_PosDisplayInfo.h
//  WinSFA
//
//  Created by winchannel on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_W_PosDisplayInfo_h
#define WinSFA_I_W_PosDisplayInfo_h

@protocol I_W_BuildInfo;

@protocol I_W_PosDisplayInfo <NSObject>

-(NSObject<I_W_BuildInfo>  *)getLeftContent; //左侧内容

-(NSObject<I_W_BuildInfo> *)getRightContent; //右侧内容

-(NSObject<I_W_BuildInfo> *)getMainContent;  //主内容

-(NSObject<I_W_BuildInfo> *)getAssistantContent; //副内容

@end

#endif
