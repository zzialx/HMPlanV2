//
//  WSInfoService.m
//  WinSFA
//
//  Created by heju on 15/10/15.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

/*
‘公告信息’ 及 ‘反馈’ 模块的service
 */
 
#import "WSInfoService.h"

#import "WSRequestHelper.h"


@interface WSInfoService ()

@property (nonatomic, strong) NSString *notifyName;
@property (nonatomic, strong) NSString *objId;
@property (nonatomic, strong) NSThread *currentThread;
@property (nonatomic, strong) NSTimer *currentTimer;

@end

@implementation WSInfoService

- (id)initWith:(NSString *)objId notify:(NSString *)name {
    self = [super init];
    if (self) {
        _objId = objId;
        _notifyName = name;
        return self;
    }
    return nil;
}


/*主界面 反馈信息模块 信息标识的轮询*/
- (void)startRequest{
    /*
     注册退出程序的通知(退出程序时，子线程终止，timer置为无效)
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancellThreadAndInvalidTimer)
                                                 name:LOGOUT
                                               object:nil];
    [self requestInfo];
    _currentThread = [[NSThread alloc]initWithTarget:self selector:@selector(startTimer) object:nil];
    [_currentThread start];
}

- (void)startTimer
{
    id  interval = [[NSUserDefaults standardUserDefaults] objectForKey:POA_NOTIFICATION_INTERVAL];
    NSTimeInterval timeInterval = 30;
    if (interval && ([interval isKindOfClass:[NSString class]] || [interval isKindOfClass:[NSNumber class]])) {
        timeInterval = [interval   intValue];
    }
    NSDictionary *userInfo = @{@"objId":self.objId,@"notifyName":self.notifyName};
    _currentTimer = [NSTimer  timerWithTimeInterval:timeInterval * 60.0f  target:self selector:@selector(requestInfo) userInfo:userInfo repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_currentTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    [[NSRunLoop currentRunLoop]  run];  
}

- (void)requestInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInfoFinished:)
                                                 name:_notifyName
                                               object:nil];
    [[WSRequestHelper shareInstance]  postRequestWith:_objId name:_notifyName];

}

- (void)updateInfoFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_notifyName object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dihonPoaTaskResDictonary = [info  objectFromJSONString];
    NSArray *dihoPoaTaskResArray = [dihonPoaTaskResDictonary objectForKey:@"dihonPoaTaskRes"];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    if ([_delegate respondsToSelector:@selector(infoService:feedback:)]) {
        NSInteger count = dihoPoaTaskResArray ? [dihoPoaTaskResArray count]:0;
        [_delegate infoService:self feedback:count];
    }
}

/**
  退出的时候要 取消当前线程 和 timer
 */
- (void)cancellThreadAndInvalidTimer {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGOUT object:nil];
    
    if (![self.currentThread isCancelled] ) {
        [self.currentThread cancel];
    }
    if ([self.currentTimer isValid]) {
        [self.currentTimer invalidate];
        self.currentTimer = nil;
    }
}

- (void)dealloc {
    
}

@end
