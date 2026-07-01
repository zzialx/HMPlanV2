//
//  MobileAutoUploadManager.m
//  WinChannelFrameWork
//
//  Created by yang on 13-8-20.
//
//

#import "WSOfflineDataManager.h"
#import "WSOffLineUploadTable.h"
#import "WSRequestHelper.h"
#import "WSStatisticsManager.h"

@interface WSOfflineDataManager ()
{
//    dispatch_source_t _sourceTimer;
    NSTimer *_timer;
}

@end

@implementation WSOfflineDataManager

static WSOfflineDataManager* instance = nil;

- (void)dealloc
{
//#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
//    dispatch_release(_sourceTimer);
//#endif
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
}

+ (WSOfflineDataManager *)sharedInstance
{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[self alloc] init];
        });
    }
    
    return instance;
}

- (void)startAutoUploadWithTimeInterval:(NSTimeInterval)timeInterval
{
    [self startAutoUploadWithDelayTime:0 andTimeInterval:timeInterval];
}

- (void)startAutoUploadWithDelayTime:(NSTimeInterval)delayTime andTimeInterval:(NSTimeInterval)timeInterval
{
    /*
    if (_sourceTimer) {
        if (!dispatch_source_testcancel(_sourceTimer)) {
            dispatch_source_cancel(_sourceTimer);
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(_sourceTimer);
#endif
    }
    
    _sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(_sourceTimer, ^{
        [self uploadFailedDatas];
    });
    
    dispatch_time_t time;
    if (delayTime > 0) {
        time = dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC);
    }
    else{
        time = DISPATCH_TIME_NOW;
    }
    dispatch_source_set_timer(_sourceTimer, time, timeInterval * NSEC_PER_SEC, 10 * NSEC_PER_SEC);
    
    dispatch_resume(_sourceTimer);
    */
    
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    
    self.isStartAutoUpload = YES;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(uploadFailedDatas) userInfo:nil repeats:YES];
    
    if (delayTime > 0) {
        NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:delayTime];
        [_timer setFireDate:fireDate];
    }
    else
    {
        [_timer fire];
    }
}
- (void)stopAutoUpload
{
    self.isStartAutoUpload = NO;
//    if (_sourceTimer && !dispatch_source_testcancel(_sourceTimer)) {
//        dispatch_source_cancel(_sourceTimer);
//    }
    
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (void)uploadFailedDatas
{
    LogTrace();
    
    [[WSStatisticsManager sharedInstance] uploadStatisticsLogs];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
        NSArray* l_failedDatas = [l_leaveStore queryWithUploadFlagType:Failed];
        
        if (l_failedDatas != nil && [l_failedDatas count] > 0) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                WSRequestHelper* l_WSRequestHelper = [WSRequestHelper shareInstance];
                for(WSOffLineUploadObject* object in l_failedDatas)
                {
                    [l_WSRequestHelper uploadFailedData:object];
                }
            });
        }
        
    });
    
}

#pragma mark - about Singleton

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (nil == instance) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end
