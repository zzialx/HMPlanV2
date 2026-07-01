//
//  I_Task_Execute.h
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Task_Execute_h
#define WinSFA_I_Task_Execute_h


typedef enum {
    
    EXECUTE_STATUS_IN_SLEEP,
    EXECUTE_STATUS_IN_RUN,
    EXECUTE_STATUS_SUCCEED,
    EXECUTE_STATUS_FAILED
    
}EXECUTE_STATUS;


@protocol IAttachment;

@protocol I_Task_ExecutorDelegate;

@protocol I_Task_Execute <NSObject>

-(NSInteger)executeType; //执行类型 －－－设计过量 I don't know where to use this method,but I think maybe in the future it will become a useful method.

-(void)setTaskExecuteId:(NSString *)executeId; //执行任务的编号

-(NSString *)getTaskExecuteId; //获得任务执行id

-(EXECUTE_STATUS)getTaskStatus; //获得任务的执行状态


-(void)setDownloadFile:(NSObject<IAttachment> *)downloadfile; //下载文件

-(NSObject<IAttachment> *)getDownloadFile;


-(void)executeCurrentTask; //执行当前的任务

-(float)getPercent; //获取执行任务的百分比

-(NSObject *)getExecuteResult;//获取执行完的运行结果

-(void)setCallBackDelegate:(NSObject<I_Task_ExecutorDelegate> *)delegate; //设置任务执行回调

- (long long)getTotalBytesRead;

- (long long)getTotalBytesExpectedToRead;

- (NSDate *)getBeginTime;

- (NSDate *)getEndTime;

@end

#endif
