//
//  WSTaskExecutor.h
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "I_Task_ExecutorDelegate.h"

@protocol I_Task_Execute;

@protocol WSTaskExecutorPoolDelegate <I_Task_ExecutorDelegate>

-(void)executeBegin:(NSObject<I_Task_Execute> *)taskobj;  //开始执行

-(void)executeInRun:(NSObject<I_Task_Execute> *)taskobj;  //执行中

-(void)executeInEnd:(NSObject<I_Task_Execute> *)taskobj;  //执行完毕

-(void)executeError:(NSObject<I_Task_Execute> *)taskobj;  //执行错误

@end


@interface WSTaskExecutorPool : NSObject<I_Task_ExecutorDelegate>{
    
    NSMutableArray  *tasklistarray; //执行列表
    
    NSMutableDictionary  *taskMap;  //执行任务的映射，方便快速定位及查找
    
    NSInteger max_pool_size;
    
    NSInteger min_pool_size;
    
    NSInteger currentConcurrentCount;
    
    id<WSTaskExecutorPoolDelegate>  callBackDelegate;
    
    
}

@property (nonatomic,strong) NSMutableArray  *tasklistarray;

@property (nonatomic,assign) NSInteger  max_pool_size;

@property (nonatomic,assign) NSInteger  min_pool_size;

@property (nonatomic, assign) NSInteger maxConcurrentCount;

@property (nonatomic,retain) id<WSTaskExecutorPoolDelegate> callBackDelegate;


+(id)shareInstance;

-(void)addExecuteObjectAndExecute:(NSObject<I_Task_Execute> *)execute;

-(NSObject<I_Task_Execute> *)lookUpTaskByTaskId:(NSString *)taskId;

-(void)cutOtherExecutorDelegateExceptThis:(NSObject<I_Task_Execute> *)execute;




@end
