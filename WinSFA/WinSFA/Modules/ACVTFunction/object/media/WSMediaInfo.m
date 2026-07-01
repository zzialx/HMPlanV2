//
//  WSMediaInfo.m
//  WinSFA
//
//  Created by winchannel on 15/4/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMediaInfo.h"
#import "IAttachment.h"

/*
    处理媒体信息
 */

@implementation WSMediaInfo

@synthesize media_file_id;    //媒体文件id

@synthesize media_file_name; //媒体文件名称

@synthesize media_file_type; //媒体文件类型

@synthesize media_file_url; //下载地址

@synthesize media_file_size; //媒体文件大小

@synthesize media_file_local_save_path; //媒体本地存储路径

@synthesize force_read_time_for_page;

@synthesize status;

@synthesize progress;

@synthesize isread;

//获取媒体文件id
-(NSString *)getMediaInfoId{
    
    return media_file_id;
}

//系统载入路径
-(NSString *)getLoadingPath{
    
    return media_file_url;
}

//文件名
-(NSString *)getFilename{
    
    return media_file_name;
}

//媒体类型
-(NSString *)getMimetype{
    
    return @"";
}

//请求路径
-(NSString *)getRequestpath{
    
    return media_file_url;
}

//请求方法
-(NSString *)getRequestMethod{
    
    return @"";
}

//是否获取进度
-(BOOL)getNeedProgress{
    
    return YES;
}

//获取文件类型
- (NSString *)getFileType {
    
    return media_file_type;
}

#pragma mark -
#pragma mark MethodForInterface method

//获取媒体文件保存路径
-(NSString *)getMediaFileSavePath{
    
    return media_file_local_save_path;
}

//本地存储路径
-(void)setMediaFileSavePath:(NSString *)localsavepath{
    
    media_file_local_save_path = localsavepath;
    
}

//获取媒体文件的下载状态
-(NSInteger)getMediaDownloadStatus{
    
    return status;
}

- (void)setMediaDownloadStatus:(NSInteger)newStatus {
    status = newStatus;
}

//获取下载的进度
- (float)getDownloadPercent{
    return progress;
}


//设置下载进程
- (void)setDownloadPercent:(float)percent{
    
    progress = percent;
}

//设置是否已阅
-(void)setIsExplored:(BOOL)explored{
    
    isread = explored;
}

//获取是否已阅
-(BOOL)getIsExplored{
    
    return isread;
}

- (NSString *)getForceReadTimeForPage {
    return force_read_time_for_page;
}


@end
