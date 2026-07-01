//
//  DownloadExecutor.h
//  ExecuteTest
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 winchannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "I_Task_Execute.h"

@class  WCBaseRequest;

@protocol WCBaseRequestDelegate;

@protocol IAttachment;




@interface DownloadExecutor : NSObject<I_Task_Execute,WCBaseRequestDelegate,NSCopying>{
    
    NSInteger process_count;
    
    NSString * taskId;
    
    __unsafe_unretained id<I_Task_ExecutorDelegate>  opdelegate;
    
    EXECUTE_STATUS  status;
    
    float complete_percent;
    
    int resultCount;
    
    NSThread  *thread;

    WCBaseRequest  *downloadRequest;
    
    NSObject<IAttachment> *attachment;
    
    long long bytesRead;
    
    long long bytesExpectedToRead;
    
    NSDate  *beginTime;
    
    NSDate  *endTime;
    
}

@property (nonatomic,strong)   NSString * taskId;

@property (nonatomic,strong)    NSObject<IAttachment> *attachment;

@property (nonatomic,assign)  EXECUTE_STATUS  status;

-(id)initWithProcessCount:(NSInteger)pc;

- (void)pasueOrResume;

- (void)excuterCancel;

@end
