//
//  BGTask.h
//  WinSFA
//
//  Created by mac on 2018/8/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BGTask : NSObject
+(instancetype)shareBGTask;
-(UIBackgroundTaskIdentifier)beginNewBackgroundTask; //开启后台任务
-(void)endBackGroundTask:(BOOL)all;
@end
