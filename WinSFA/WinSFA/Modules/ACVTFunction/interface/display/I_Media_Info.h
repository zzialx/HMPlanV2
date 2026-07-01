//
//  I_Media_Info.h
//  WinSFA
//
//  Created by winchannel on 15/4/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Media_Info_h
#define WinSFA_I_Media_Info_h

@protocol  I_Media_Info <NSObject>

-(NSString *)getMediaInfoId;       //获取媒体文件id

-(NSString *)getMediaFileName;    //获取媒体文件名称

-(NSString *)getMediaFileType;    //获取媒体文件类型

-(NSNumber *)getMediaFileLength;  //获取媒体文件大小

-(NSString *)getMediaFileUrl;  //获取媒体文件下载路径

-(NSInteger)getMediaDownloadStatus; //获取媒体文件的下载状态

-(float)getDownloadPercent;  //获取下载的进度

-(void)setDownloadPercent:(float)percent; //设置下载进度

@optional

-(NSString *)getMediaFileSavePath; //获取媒体文件保存路径

-(void)setMediaFileSavePath:(NSString *)localsavepath; // 本地存储路径

@end


#endif
