//
//  WSTaskExecutor.m
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTaskExecutorPool.h"
#import "I_Task_Execute.h"
#import "I_Task_ExecutorDelegate.h"


#define MAX_POOL_SIZE 100
#define MIN_POOL_SIZE 5

#define MAX_CONCURRENT_COUNT 2

// a simple Thread pool implementation
@implementation WSTaskExecutorPool

@synthesize tasklistarray;

@synthesize max_pool_size;

@synthesize min_pool_size;

@synthesize callBackDelegate;

static WSTaskExecutorPool  *executionPool;

+(id)shareInstance{
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        executionPool =[[WSTaskExecutorPool alloc] init];
    });
    
    return executionPool;
}

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        max_pool_size = MAX_POOL_SIZE;
        
        min_pool_size = MIN_POOL_SIZE;
        
        tasklistarray =[[NSMutableArray alloc] initWithCapacity:MIN_POOL_SIZE];
        
        taskMap =[[NSMutableDictionary alloc] init];
        
        self.maxConcurrentCount = MAX_CONCURRENT_COUNT;
        
        currentConcurrentCount = 0;
        
        return self;
    
    }
    
    return nil;
    
}

- (void)start
{
    for (NSObject<I_Task_Execute> *execute in tasklistarray) {
        if (currentConcurrentCount < self.maxConcurrentCount) {
            if ([execute getTaskStatus] == EXECUTE_STATUS_IN_SLEEP) {
                [execute executeCurrentTask];
                currentConcurrentCount++;
            }
        }
        else {
            break;
        }
        
    }
}

-(void)addExecuteObjectAndExecute:(NSObject<I_Task_Execute> *)execute{
    
    [tasklistarray addObject:execute];
    
    [taskMap setObject:execute forKey:[execute  getTaskExecuteId]];
    
    [execute setCallBackDelegate:self];
    
   if (currentConcurrentCount < self.maxConcurrentCount) {
       
       [execute executeCurrentTask];
       
       currentConcurrentCount++;
    
    }
    
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self){
        
        if (nil == executionPool) {
            
            executionPool = [super allocWithZone:zone];
        
        }
    }
    return executionPool;
}

-(id)copy
{
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)removeTask:(NSObject<I_Task_Execute> *)task
{
    NSInteger   index = [tasklistarray indexOfObject:task];
    
    [tasklistarray removeObjectAtIndex:index];
    
    [task setCallBackDelegate:nil];
    
    [taskMap removeObjectForKey:[task getTaskExecuteId]];
    
    currentConcurrentCount--;
}

#pragma mark -
#pragma mark I_Task_ExecutorDelegate method

-(void)executeBegin:(NSObject<I_Task_Execute> *)taskobj{
    
    if ([callBackDelegate respondsToSelector:@selector(executeBegin:)]) {
        
        [callBackDelegate executeBegin:taskobj];
    }
    
}

-(void)executeInRun:(NSObject<I_Task_Execute> *)taskobj{
    
    

    if ([callBackDelegate respondsToSelector:@selector(executeInRun:)]) {
            
        [callBackDelegate executeInRun:taskobj];
            
    }
    
}

-(void)executeInEnd:(NSObject<I_Task_Execute> *)taskobj{
    
    if ([callBackDelegate respondsToSelector:@selector(executeInEnd:)]) {
        
        [callBackDelegate executeInEnd:taskobj];
        
    }
    
    [self removeTask:taskobj];
    
    [self start];
    
}

- (void)executeError:(NSObject<I_Task_Execute> *)taskobj {
    
    if ([callBackDelegate respondsToSelector:@selector(executeError:)]) {
        
        [callBackDelegate executeError:taskobj];
    }
    
    [self removeTask:taskobj];
    
    [self start];
    
}

-(NSObject<I_Task_Execute> *)lookUpTaskByTaskId:(NSString *)taskId{
    
    NSObject<I_Task_Execute> *taskObject = [taskMap objectForKey:taskId];
    
    if (taskObject==nil) {
        
        return nil;
    }
    
    return taskObject;
}

-(void)cutOtherExecutorDelegateExceptThis:(NSObject<I_Task_Execute> *)execute{
    
    NSString *taskId = [execute getTaskExecuteId];
    
    for (int i=0; i<[[taskMap allKeys] count]; i++) {
        
        NSString *key =[[taskMap allKeys] objectAtIndex:i];
        
        NSObject<I_Task_Execute> *other_executor =[taskMap objectForKey:key];
        
        if (![[other_executor getTaskExecuteId] isEqualToString:taskId]) {

            
        [other_executor setCallBackDelegate:nil];
            
        }else{
            
           [other_executor setCallBackDelegate:self];
        }
        
        
        [taskMap setObject:other_executor forKey:key];
    }
    
}
@end
