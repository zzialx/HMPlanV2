//
//  WSTimerManager.h
//  WinSFA
//
//  Created by admin on 2022/11/16.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^showAlert)(void);

NS_ASSUME_NONNULL_BEGIN

@interface WSTimerManager : NSObject

+ (WSTimerManager*)sharedManager;
/// - Parameters:
   ///   - timerKey: 倒计时key，需要保证唯一
   ///   - interval: 间隔时间
   ///   - repeats: 是否重复
   ///   - eventHandle: 回调

- (void)scheduleTimerKey:(NSString*)timerKey interval:(NSInteger)interval repeats:(BOOL)repeats eventHandle:(showAlert)eventHandle;

- (void)cancelTask:(NSString*)timerKey;

@end

NS_ASSUME_NONNULL_END
