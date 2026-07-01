//
//  WSDownloadUtil.h
//  WinSFA
//
//  Created by yang on 15/4/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDownloadUtil : NSObject

+ (NSString *)getDownloadDirectory;

+ (NSString *)getLocalFileNameWithUrl:(NSString *) url fileTpye:(NSString *)fileType;

+ (NSString *)getLocalFileAbsolutePathWithUrl:(NSString *) url fileTpye:(NSString *)fileType;

@end
