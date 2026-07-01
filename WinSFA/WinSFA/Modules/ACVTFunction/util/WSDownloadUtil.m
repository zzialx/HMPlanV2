//
//  WSDownloadUtil.m
//  WinSFA
//
//  Created by yang on 15/4/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDownloadUtil.h"

#define ROOT_WORKING_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]

@implementation WSDownloadUtil

+ (NSString *)getDownloadDirectory
{
    NSString  *downloadDir = [ROOT_WORKING_DIRECTORY stringByAppendingPathComponent:@"download"];
    
    NSFileManager  *filemanager =[NSFileManager defaultManager];
    
    if (![filemanager fileExistsAtPath:downloadDir]) {
        [filemanager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return downloadDir;
}

+ (NSString *)getLocalFileNameWithUrl:(NSString *)url fileTpye:(NSString *)fileType
{
    /*
    return [NSString stringWithFormat:@"%@.%@", [NSString md5:url], fileType];
     */
    
    NSArray *components = [url componentsSeparatedByString:@"/"];
    NSString *tmpfileName = [components lastObject];
    NSString *localName = [[tmpfileName componentsSeparatedByString:@"."] firstObject];
    return [NSString stringWithFormat:@"%@.%@",localName, fileType];
}

+ (NSString *)getLocalFileAbsolutePathWithUrl:(NSString *)url fileTpye:(NSString *)fileType
{
    NSString *dir = [WSDownloadUtil getDownloadDirectory];
    NSString *fileName = [WSDownloadUtil getLocalFileNameWithUrl:url fileTpye:fileType];
    
    return [dir stringByAppendingPathComponent:fileName];
}

@end
