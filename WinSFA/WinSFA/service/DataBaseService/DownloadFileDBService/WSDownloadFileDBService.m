//
//  WSDownloadFileDBService.m
//  WinSFA
//
//  Created by yang on 15/4/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDownloadFileDBService.h"
#import "WSDownloadFileTable.h"
#import "IAttachment.h"
#import "WSMediaInfo.h"
#import "WSDownloadUtil.h"
#import "I_Task_Execute.h"

@implementation WSDownloadFileDBService

+ (BOOL)insertDownloadFileData:(NSObject<I_Task_Execute> *)executeTask
{
    NSObject<IAttachment> *downloadFile = [executeTask getDownloadFile];
    
    if ([downloadFile getRequestpath] == nil) {
        return NO;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //empid
    NSString *emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [array addObject:emp_id ? emp_id : [NSNull null]];
    
    // biz_date
    NSString *biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [array addObject:biz_date ? biz_date : [NSNull null]];
    
    //acvt_id
    [array addObject:[NSNull null]];
    
    //file_id
    [array addObject:[downloadFile getMediaInfoId]];
    
    //file_name
    [array addObject:[downloadFile getFilename] ? [downloadFile getFilename] : [NSNull null]];
    
    //file_url
    [array addObject:[downloadFile getRequestpath]];
    
    //file_length
    [array addObject:[NSNull null]];
    
    //file_download_size
    [array addObject:[NSNull null]];
    
    //file_type
    [array addObject:[downloadFile getFileType] ? [downloadFile getFileType] : [NSNull null]];
    
    //file_save_path
    /*
    [array addObject:[WSDownloadUtil getLocalFileNameWithUrl:[downloadFile getRequestpath] fileTpye:[downloadFile getFileType]]];
     */
    [array addObject:[NSString stringWithFormat:@"%@.%@",[downloadFile getFilename],[downloadFile getFileType]]];

    //file_download_status
    [array addObject:[NSString stringWithFormat:@"%ld",(long)[downloadFile getMediaDownloadStatus]]];
    
    //file_download_begin_time
    [array addObject:[NSNull null]];
    
    //file_download_end_time
    [array addObject:[NSNull null]];
    
    //file_expire_time
    [array addObject:[NSNull null]];
    
    return [[WSDownloadFileTable sharedTable] insertWithFileArray:array];
}

+ (BOOL)updateDownloadFileData:(NSObject<I_Task_Execute> *)executeTask
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *whereN = [NSArray arrayWithObjects:@"empid", @"file_url" , nil];
    NSArray *whereV = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:empid], [[executeTask getDownloadFile] getRequestpath],nil];
    
    
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    [names addObject:@"file_download_status"];
    [values addObject:[NSString stringWithFormat:@"%d", [executeTask getTaskStatus]]];
    
    [names addObject:@"file_download_size"];
    [values addObject:[NSString stringWithFormat:@"%lld", [executeTask getTotalBytesRead]]];
    
    [names addObject:@"file_length"];
    [values addObject:[NSString stringWithFormat:@"%lld", [executeTask getTotalBytesExpectedToRead]]];
    
    if ([executeTask getBeginTime]) {
        [names addObject:@"file_download_begin_time"];
        [values addObject:[WSCurrentTime formatDataToString:[executeTask getBeginTime]]];
    }
    
    if ([executeTask getEndTime]) {
        [names addObject:@"file_download_end_time"];
        [values addObject:[WSCurrentTime formatDataToString:[executeTask getEndTime]]];
    }
    
    return [[WSDownloadFileTable sharedTable] updateWithNames:names values:values whereName:whereN whereValue:whereV];
}

+ (WSDownloadFileObject *)queryDownloadFileDataWithUrl:(NSString *)url
{
    NSArray *array = [[WSDownloadFileTable sharedTable] queryWithFileURL:url];
    
    if (array == nil || [array count] == 0) {
        return nil;
    }
    
    WSDownloadFileObject *object = [array firstObject];
    [object setFile_save_path:[[WSDownloadUtil getDownloadDirectory] stringByAppendingPathComponent:object.file_save_path]];
    
//    WSMediaInfo *mediaInfo = [[WSMediaInfo alloc] init];
//    [mediaInfo setMedia_file_id:object.file_id];
//    [mediaInfo setMedia_file_local_save_path:[[WSDownloadUtil getDownloadDirectory] stringByAppendingPathComponent:object.file_save_path]];
//    [mediaInfo setMedia_file_type:object.file_type];
//    [mediaInfo setMedia_file_size:[object.file_length stringValue]];
//    [mediaInfo setMedia_file_url:object.file_url];
//    [mediaInfo setMediaDownloadStatus:[object.file_download_status integerValue]];
    
    return object;
}

@end
