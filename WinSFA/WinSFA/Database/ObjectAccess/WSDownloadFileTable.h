//
//  WSDownloadFileTable.h
//  WinSFA
//
//  Created by winchannel on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDownloadFileTable : WSSqliteUtil


+ (WSDownloadFileTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;

//插入数据
- (BOOL)insertWithFileArray:(NSArray *)fileValues;

//根据url查询数据
- (NSArray *)queryWithFileURL:(NSString *)aURL;

//根据url更新数据
- (BOOL)updateWithFileURL:(NSString *)aURL status:(NSString*)file_download_status;

//根据url更新下载数据
- (BOOL)updateWithFileURL:(NSString *)aURL status:(NSString*)file_download_status file_szie:(NSNumber *)size downloadSize:(NSNumber *)downloadsize;


- (BOOL)insertWithFileURL:(NSString *)aURL status:(NSString*)file_download_status file_szie:(NSNumber *)size downloadSize:(NSNumber *)downloadsize fileName:(NSString *)fileName;
@end
