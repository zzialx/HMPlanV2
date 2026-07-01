//
//  I_Task_ExecutorDelegate.h
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

@protocol I_Task_Execute;
#ifndef WinSFA_I_Task_ExecutorDelegate_h
#define WinSFA_I_Task_ExecutorDelegate_h

@protocol I_Task_ExecutorDelegate <NSObject>

-(void)executeBegin:(NSObject<I_Task_Execute> *)taskobj;  //开始执行

-(void)executeInRun:(NSObject<I_Task_Execute> *)taskobj;  //执行中

-(void)executeInEnd:(NSObject<I_Task_Execute> *)taskobj;  //执行完毕

-(void)executeError:(NSObject<I_Task_Execute> *)taskobj;  //执行错误

@end

#endif
