//
//  MobileAutoUploadManager.h
//  WinChannelFrameWork
//
//  Created by yang on 13-8-20.
//
//

#import <Foundation/Foundation.h>

@interface WSOfflineDataManager : NSObject

+ (WSOfflineDataManager *)sharedInstance;

@property (nonatomic, assign) BOOL isStartAutoUpload;

- (void)startAutoUploadWithTimeInterval:(NSTimeInterval)timeInterval;

- (void)startAutoUploadWithDelayTime:(NSTimeInterval)delayTime andTimeInterval:(NSTimeInterval)timeInterval;

- (void)stopAutoUpload;

- (void)uploadFailedDatas;

@end
