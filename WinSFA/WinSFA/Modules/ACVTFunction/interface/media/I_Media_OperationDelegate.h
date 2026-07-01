//
//  I_Media_OperationDelegate.h
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Media_OperationDelegate_h
#define WinSFA_I_Media_OperationDelegate_h

@protocol I_Media;

@protocol I_Media_OperationDelegate <NSObject>


//开始播放当前媒体
-(void)beginPlayCurrentMedia:(NSObject<I_Media> *)widget;
//当前媒体已经在播放阶段
-(void)currentMediaInPlay:(NSObject<I_Media> *)widget;
//当前媒体暂停播放
-(void)currentMediaInPause:(NSObject<I_Media> *)widget;
//当前媒体播放完毕
-(void)currentMediaPlayEnd:(NSObject<I_Media> *)widget;
//当前媒体播放错误
-(void)currentMediaPlayError:(NSObject<I_Media> *)widget;

@end

#endif
