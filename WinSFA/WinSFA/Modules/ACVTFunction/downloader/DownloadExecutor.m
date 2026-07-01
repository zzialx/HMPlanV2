//
//  DownloadExecutor.m
//  ExecuteTest
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 winchannel. All rights reserved.
//

#import "DownloadExecutor.h"
#import "I_Task_ExecutorDelegate.h"
#import "WCBaseRequest.h"
#import "IAttachment.h"
#import "WSDownloadFileDBService.h"
#import "WSDownloadUtil.h"
#import "WSCheckerFactory.h"
#import "WSCheckInfo.h"


@implementation DownloadExecutor
@synthesize attachment;
@synthesize status;
@synthesize taskId;

-(id)copy{
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    
    return self;
}
- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        taskId = 0;
        
        [self setStatus:EXECUTE_STATUS_IN_SLEEP];
        
    }
    
    return self;
}

-(id)initWithProcessCount:(NSInteger)pc{
    
    self = [self init];
    
    if (self) {
        
        process_count = pc;
        
        return self;
    
    }
    
    return nil;
}
-(void)setDownloadFile:(NSObject<IAttachment> *)downloadfile{
    
    attachment = downloadfile;
    
    [[self getDownloadFile] setMediaDownloadStatus:status];
    
    NSString *filesavepath = [WSDownloadUtil getLocalFileAbsolutePathWithUrl:[[self getDownloadFile] getFilename] fileTpye:[[self getDownloadFile] getFileType]];
    [[self getDownloadFile] setMediaFileSavePath:filesavepath];
    
    if ([WSDownloadFileDBService queryDownloadFileDataWithUrl:[[self getDownloadFile] getRequestpath]] == nil) {
        
        [WSDownloadFileDBService insertDownloadFileData:self];
    }
    
}
-(NSObject<IAttachment> *)getDownloadFile{
    
    return attachment;
    
}

-(void)start{
    
    beginTime = [NSDate date];
    
    [self setStatus:EXECUTE_STATUS_IN_RUN];
    
    if ([opdelegate respondsToSelector:@selector(executeBegin:)]) {
        
        [opdelegate executeBegin:self];
    }
    
    downloadRequest =[[WCBaseRequest alloc] init];
    
    downloadRequest.requestdelegate = self;
    
    [downloadRequest doDownloadFile:attachment shouldResume:YES];
    
}

-(void)executeCurrentTask{

    [self start];
    
}

- (void)excuterCancel {
    [downloadRequest.downLoadOperation cancel];
}


- (void)pasueOrResume  {
    [downloadRequest pasueOrResumeRequest];
}
 

-(NSInteger)executeType{
    
    return 0;
}

-(void)setTaskExecuteId:(NSString *)executeId{
    
    taskId = executeId;
}

- (EXECUTE_STATUS)getTaskStatus{
      return status;
}


-(void)setCallBackDelegate:(NSObject<I_Task_ExecutorDelegate> *)delegate{
    
    opdelegate = delegate;
    
}
-(float)getPercent{
    
    return complete_percent;
}

-(NSString *)getTaskExecuteId{
    
    return taskId ;
}


- (long long)getTotalBytesRead {
    return bytesRead;
}

- (long long)getTotalBytesExpectedToRead {
    return bytesExpectedToRead;
}

- (NSDate *)getBeginTime {
    return beginTime;
}

- (NSDate *)getEndTime {
    return endTime;
}

- (void)setStatus:(EXECUTE_STATUS)newStatus{
    status = newStatus;
    [[self getDownloadFile] setMediaDownloadStatus:newStatus];
    [WSDownloadFileDBService updateDownloadFileData:self];
}

- (void)reportSuccess {
    
    [self setStatus:EXECUTE_STATUS_SUCCEED];
  
    if ([opdelegate respondsToSelector:@selector(executeInEnd:)]) {
        
        [opdelegate executeInEnd:self];
        
    }
    
}

- (void)reportFailed {
    
    [self setStatus:EXECUTE_STATUS_FAILED];
   
    
    if ([opdelegate respondsToSelector:@selector(executeError:)]) {
        
        [opdelegate executeError:self];
        
    }
    
}

- (NSObject *)getExecuteResult {
    return nil;
}

#pragma mark -
#pragma mark WCBaseRequestDelegate

-(void)sendContentDataWithSuccess:(NSData *)data{
    
    endTime = [NSDate date];
    
    NSObject <I_CheckerInfo> *checkInfo = [[WSCheckInfo alloc] init];
    [checkInfo setCheckerType:[[self getDownloadFile] getFileType]];
    [checkInfo setCheckerObject:[[self getDownloadFile] getMediaFileSavePath]];
    
    NSObject<I_Checker> *checker = [[WSCheckerFactory shareInstance] createChecker:checkInfo];
    
    if (checker) {
        if ([checker checkObjectIsValidate:[checkInfo getCheckerObject]]) {
            [self reportSuccess];
        }
        else {
            //文件已损坏，删除文件。
            if ([[NSFileManager defaultManager] fileExistsAtPath:[[self getDownloadFile] getMediaFileSavePath]]) {
                [[NSFileManager defaultManager] removeItemAtPath:[[self getDownloadFile] getMediaFileSavePath] error:NULL];
            }
            bytesRead = 0;
            [self reportFailed];
        }
    }
    else {
        [self reportSuccess];
    }

}

-(void)sendErrorContentWithFailed:(NSError *)error{
    
    [self reportFailed];
}

- (void)sendProgressWithBytesRead:(long long)totalBytesRead andBytesExpected:(long long)totalBytesExpectedToRead {
    
    bytesRead = totalBytesRead;
    
    bytesExpectedToRead = totalBytesExpectedToRead;
    
    complete_percent = (float)bytesRead/bytesExpectedToRead;
    NSLog(@"complete_percent-------%f",complete_percent);
    
    [attachment setDownloadPercent:complete_percent];
    
    [self setStatus:EXECUTE_STATUS_IN_RUN];
    
    if ([opdelegate respondsToSelector:@selector(executeInRun:)]) {
        [opdelegate executeInRun:self];
        
    }
}

@end
