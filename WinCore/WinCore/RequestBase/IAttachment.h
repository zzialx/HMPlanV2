//
//  IAttachment.h
//  WinCore
//
//  Created by winchannel on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinCore_IAttachment_h
#define WinCore_IAttachment_h

#import <Foundation/Foundation.h>

@protocol IAttachment <NSObject>

@optional
//获取媒体文件id
-(NSString *)getMediaInfoId;

//系统载入路径
-(NSString *)getLoadingPath;

//文件名
-(NSString *)getFilename;

//文件类型
-(NSString *)getFileType;

//媒体类型
-(NSString *)getMimetype;

//请求路径
-(NSString *)getRequestpath; //url

//请求方法
-(NSString *)getRequestMethod;

//是否获取进度
-(BOOL)getNeedProgress;

@optional
//获取每页强制阅读时间，以秒为单位
-(NSString *)getForceReadTimeForPage;

#pragma mark -
#pragma mark MethodForInterface method

//获取媒体文件保存路径
-(NSString *)getMediaFileSavePath;

//本地存储路径
-(void)setMediaFileSavePath:(NSString *)localsavepath;

//获取媒体文件的下载状态
-(NSInteger)getMediaDownloadStatus;
//设置媒体的下载状态
-(void)setMediaDownloadStatus:(NSInteger)newStatus;

//获取下载的进度
-(float)getDownloadPercent;
//设置下载进度
-(void)setDownloadPercent:(float)percent;

//获取是否已预览
-(BOOL)getIsExplored;
//设置是否已预览
-(void)setIsExplored:(BOOL)explored;


@end

#endif
