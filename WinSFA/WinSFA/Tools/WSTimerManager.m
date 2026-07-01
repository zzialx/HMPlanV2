//
//  WSTimerManager.m
//  WinSFA
//
//  Created by admin on 2022/11/16.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSTimerManager.h"

@interface WSTimerManager ()
/// 每一个key都对应唯一的一个定时器， 固用字典存储
@property(nonatomic,strong)NSMutableDictionary * timersDic;

/// 因为涉及到多线程同时读写，为了避免出现错误，执行数据变更时需要加锁操作
@property(nonatomic,strong)dispatch_semaphore_t  semaphore;

/// 签退提醒
@property(nonatomic,copy)showAlert showSigtOutMsg;

@end

@implementation WSTimerManager

+ (WSTimerManager*)sharedManager {
    static dispatch_once_t onceToken;
    static WSTimerManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WSTimerManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.timersDic = [NSMutableDictionary dictionaryWithCapacity:0];
        self.semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)scheduleTimerKey:(NSString*)timerKey interval:(NSInteger)interval repeats:(BOOL)repeats eventHandle:(showAlert)eventHandle{
    
    NSTimer * timer = [self.timersDic objectForKey:timerKey];
    if(timer==nil){
        timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(run) userInfo:nil repeats:repeats];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        [self.timersDic setObject:timer forKey:timerKey];
        dispatch_semaphore_signal(self.semaphore);
        self.showSigtOutMsg = eventHandle;
        if(!repeats){
            [self cancelTask:timerKey];
        }
    }
}

- (void)run {
    
    //NSLog(@"run-----------------");
    if(self.showSigtOutMsg){
        self.showSigtOutMsg();
    }
}

- (void)cancelTask:(NSString*)timerKey {
    
    NSTimer * timer = [self.timersDic objectForKey:timerKey];
    if (timer) {
        [timer invalidate];
    }
    if (self.timersDic.allKeys.count > 0) {
        [self.timersDic removeObjectForKey:timerKey];
    }
}

@end
