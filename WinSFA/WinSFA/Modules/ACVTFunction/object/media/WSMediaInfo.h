//
//  WSMediaInfo.h
//  WinSFA
//
//  Created by winchannel on 15/4/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAttachment.h"


@interface WSMediaInfo : NSObject<IAttachment>{
    
    NSString  *media_file_id;    //媒体文件id
    
    NSString  *media_file_name; //媒体文件名称
    
    NSString  *media_file_type; //媒体文件类型
    
    NSString  *media_file_url; //下载地址
    
    NSString  *media_file_size; //媒体文件大小
    
    NSString  *media_file_local_save_path;//本地存储路径
    
    NSString  *force_read_time_for_page;//每页强制阅读时间
    
    NSInteger status;
    
    BOOL isread;
    
    float  progress;
    
}


@property (nonatomic,strong)  NSString  *media_file_id;    //媒体文件id

@property (nonatomic,strong)  NSString  *media_file_name; //媒体文件名称

@property (nonatomic,strong)  NSString  *media_file_type; //媒体文件类型

@property (nonatomic,strong)  NSString  *media_file_url; //下载地址

@property (nonatomic,strong)  NSString  *media_file_size; //媒体文件大小

@property (nonatomic,strong)  NSString  *media_file_local_save_path; //本地存储路径

@property (nonatomic,strong)  NSString  *force_read_time_for_page; //每页强制阅读时间

@property (nonatomic,assign) NSInteger status;  //状态

@property (nonatomic,assign) BOOL isread;

@property (nonatomic,assign) float progress;  //下载进度

@end
