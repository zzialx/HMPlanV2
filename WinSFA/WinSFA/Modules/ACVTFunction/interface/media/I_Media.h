//
//  I_Media.h
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "I_Media_Info.h"
#import "I_Media_OperationDelegate.h"

#ifndef WinSFA_I_Media_h
#define WinSFA_I_Media_h

@protocol IAttachment;


@protocol I_Media <NSObject>


//设置媒体信息
-(void)setMediaInfo:(NSObject<IAttachment> *)mediaInfo;

//执行媒体播放
-(void)playTheMeida;

//设置媒体操作代理
-(void)setMediaPlayDelegate:(NSObject<I_Media_OperationDelegate> *)operationDelegate;

@optional
//设置媒体外观界面
-(id)initMediaFrame:(CGRect)frame;

//暂停媒体播放
-(void)pauseTheMeida;


@end


#endif
