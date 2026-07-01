//
//  WSTouchRecord.m
//  WinSFA
//
//  Created by zhangke on 14/6/30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSTouchRecord.h"

@interface WSTouchRecord (){
    NSTimer* _timer;
    NSInteger seconds;
    NSInteger lockoutTime;
}

@end

static WSTouchRecord*  sharedDataManager =nil;



@implementation WSTouchRecord

+ (WSTouchRecord *) sharedManager
{
    @synchronized(self)
    {
        if(nil  ==  sharedDataManager)
        {
            sharedDataManager = [[self alloc] init];
        }
    }
    return sharedDataManager;
}

-(id)init
{
    self=[super init];
    if(self){
        NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_TIMEOUT];
        lockoutTime=lockout.integerValue;
    }
    return self;
}

-(void)resetTimer
{
    if(self.login){
        [self stopTimer];
        _timer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(addRecordTime:) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer
{
    if(_timer){
        [_timer invalidate];
        _timer=nil;
        seconds=0;
    }
}

-(void)addRecordTime:(NSTimer*)timer
{
    seconds++;
    if(seconds/(60*lockoutTime)==1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showLockScreenVC" object:nil userInfo:nil];
        [self stopTimer];
        self.login=NO;
    }
}


@end
