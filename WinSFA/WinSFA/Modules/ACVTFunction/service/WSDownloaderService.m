//
//  WSDownloaderService.m
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDownloaderService.h"
#import "WSTaskExecutorPool.h"
#import "I_W_BuildInfo.h"
#import "DownloadExecutor.h"
#import "WSInterAction.h"
#import "WSDownloadFileTable.h"
#import "IAttachment.h"
#import "WSDownloadFileDBService.h"

@interface WSDownloaderService ()<WSTaskExecutorPoolDelegate>

@end

@implementation WSDownloaderService

-(id)init{
    self = [super init];
    if (self) {
        
        interactionMap =[[NSMutableDictionary alloc] init];
        
        return self;
    }
    return nil;
    
}


-(void)executeFileDownload:(WSInterAction *)interaction{
    

    
    
    
    currentbuildInfo = (NSObject<I_W_BuildInfo> *)[interaction inner_param];
    
    [interactionMap setObject:interaction forKey:[[currentbuildInfo getMediaInfo] getLoadingPath]];
    
    DownloadExecutor  *downloadExecutor =[[DownloadExecutor alloc] init];
    
    [downloadExecutor setTaskExecuteId:[currentbuildInfo getAcvtQstId]];
    
    [downloadExecutor setDownloadFile:[currentbuildInfo getMediaInfo]];
    
    [[WSTaskExecutorPool shareInstance] setCallBackDelegate:self];
    
    [[WSTaskExecutorPool shareInstance] addExecuteObjectAndExecute:downloadExecutor];
    
}


-(void)executeGetFileStatus:(WSInterAction *)interaction{
    
    currentbuildInfo = (NSObject<I_W_BuildInfo> *)[interaction inner_param];
    
    [interactionMap setObject:interaction forKey:[[currentbuildInfo getMediaInfo] getLoadingPath]];
    
    NSObject<I_Task_Execute>  *downloadExecutor = [[WSTaskExecutorPool shareInstance] lookUpTaskByTaskId:[currentbuildInfo getAcvtQstId]];
    
    if (downloadExecutor!=nil) {  //如果下载器存在，则将其他下载器的下载回调代理设置成空
        
        [[WSTaskExecutorPool shareInstance] cutOtherExecutorDelegateExceptThis:downloadExecutor];
        
        [[WSTaskExecutorPool shareInstance] setCallBackDelegate:self];
         
        
    }else{
        
        NSObject<IAttachment> *mediaInfo = [currentbuildInfo getMediaInfo];
          //0 是未下载  1 是正在下载   2 是下载完成  3 是下载过程出错
  
        WSDownloadFileObject *downloadObj = [WSDownloadFileDBService queryDownloadFileDataWithUrl:[mediaInfo getRequestpath]];
        
        EXECUTE_STATUS status = (EXECUTE_STATUS)[downloadObj.file_download_status integerValue];
        if (status == EXECUTE_STATUS_IN_RUN) {
            status = EXECUTE_STATUS_FAILED;
        }
        
        [mediaInfo setMediaDownloadStatus:status];
        
        [mediaInfo setMediaFileSavePath:[downloadObj  file_save_path] ];
        
        if ([downloadObj file_length] && [downloadObj file_download_size] && [[downloadObj file_length] floatValue] > 0) {
            [mediaInfo setDownloadPercent:[[downloadObj file_download_size] floatValue]/[[downloadObj file_length] floatValue]];
        }
        
        currentInteraction = [interactionMap objectForKey:[[currentbuildInfo getMediaInfo] getLoadingPath]];

        [currentInteraction setExecute_result:currentbuildInfo];
        
        if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteSuccessed:andResultObject:)]) {
            
            [self.service_call_back_delegate serviceExecuteSuccessed:self andResultObject:currentInteraction];
        }
        
        
        [[WSTaskExecutorPool shareInstance] setCallBackDelegate:nil];
    }
    
    
}

#pragma mark -
#pragma mark 


-(void)executeBegin:(NSObject<I_Task_Execute> *)taskobj{
    
    
    
    
}

-(void)executeInRun:(NSObject<I_Task_Execute> *)taskobj{
    

    
    currentInteraction = [interactionMap objectForKey:[[taskobj getDownloadFile] getLoadingPath]];
    
    currentbuildInfo = (NSObject<I_W_BuildInfo> *)[currentInteraction  inner_param];
    
    [currentbuildInfo setI_Media_Info:[taskobj getDownloadFile]];
    
    [currentInteraction setExecute_result:currentbuildInfo];
    
    if ([self.service_call_back_delegate respondsToSelector:@selector(serviceInExeute:andResultObject:)]) {
        
        [self.service_call_back_delegate serviceInExeute:self andResultObject:currentInteraction];
        
    }
    
}


-(void)executeInEnd:(NSObject<I_Task_Execute> *)taskobj{
    
    currentInteraction = [interactionMap objectForKey:[[taskobj getDownloadFile] getLoadingPath]];
    
    currentbuildInfo = (NSObject<I_W_BuildInfo> *)[currentInteraction  inner_param];
    
    [currentbuildInfo setI_Media_Info:[taskobj getDownloadFile]];
    
    [currentInteraction setExecute_result:currentbuildInfo];

    if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteSuccessed:andResultObject:)]) {
        
        [self.service_call_back_delegate serviceExecuteSuccessed:self andResultObject:currentInteraction];
    }
    
    [[WSTaskExecutorPool shareInstance] setCallBackDelegate:nil];
    
}

- (void)executeError:(NSObject<I_Task_Execute> *)taskobj {
    
    [currentbuildInfo setI_Media_Info:[taskobj getDownloadFile]];
    
    [currentInteraction setExecute_result:currentbuildInfo];
    
    if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteFailed:andResultObject:andError:)]) {
        
        [self.service_call_back_delegate serviceExecuteFailed:self andResultObject:currentInteraction andError:nil];
        
    }
}


@end
