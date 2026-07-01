//
//  I_M_ViewDelegate.h
//  WinSFA
//
//  Created by winchannel on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_M_ViewDelegate_h
#define WinSFA_I_M_ViewDelegate_h

@protocol I_M_View;

@protocol I_M_ViewDelegate <NSObject>

-(void)MessageView:(NSObject<I_M_View> *)messageView clickAtButtonIndex:(NSInteger)index;

-(void)MessageViewClickAtCancel:(NSObject<I_M_View> *)messageView;

@end

#endif
