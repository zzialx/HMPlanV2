//
//  SLDownLoadModel.h
//  SLMultiDownLoadManager
//
//  Created by sunlei on 16/8/3.
//  Copyright © 2016年 sunlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownLoadHeader.h"

typedef enum modelFileType {
    
    imageType = 0,
    H5Type

} ModelFileType;

@interface SLDownLoadModel : NSObject<NSCoding>



@property (nonatomic, copy)     NSString * ID;                                  //对应着富媒体表中的ID
@property (nonatomic, copy)     NSString * filePath;                     //压缩包路径
@property (nonatomic, copy)     NSString * toFilePath;                   //解压缩路径
@property (nonatomic, strong)   NSURLSessionDownloadTask *downLoadTask;  //当前资源下载任务
@property (nonatomic, assign)   NSInteger ModelFileType;
@property (atomic, assign)   DownLoadState downLoadState;             //当前下载状态

@property (nonatomic, copy)     NSString *fileUUID;             //生成的UUID作为文件名
@property (nonatomic, copy)     NSString *title;                //下载资源的标题
@property (nonatomic, copy)     NSString *downLoadUrlStr;       //下载资源的URL

@property (nonatomic, assign)   float     totalByetes;          //下载资源的总大小
@property (nonatomic, assign)   float     downLoadedByetes;     //当前已下载量的大小
@property (nonatomic, assign)   float     downLoadSpeed;        //下载速度
@property (nonatomic, assign)   float     downLoadProgress;     //下载进度  百分比

@property (nonatomic, assign)   BOOL      isDelete;             //是否要被删除
@property (nonatomic, assign)   BOOL      isEditStatus;         //是否在编辑状态

@end
