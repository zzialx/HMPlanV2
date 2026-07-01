//
//  I_M_View.h
//  WinSFA
//
//  Created by winchannel on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_M_View_h
#define WinSFA_I_M_View_h

@protocol I_M_Display;

@protocol I_M_ViewDelegate;

@protocol I_M_View <NSObject>

-(void)showCurrentMessageView:(NSObject<I_M_Display> *)messageobj;

-(void)hiddenMessageView;

-(void)setMessageDelegate:(NSObject<I_M_ViewDelegate> *)operationdelegate;

@end


#endif
