//
//  WSDownloadFileDBService.h
//  WinSFA
//
//  Created by yang on 15/4/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol I_Task_Execute;

@interface WSDownloadFileDBService : NSObject

+ (BOOL)insertDownloadFileData:(NSObject<I_Task_Execute> *)executeTask;

+ (BOOL)updateDownloadFileData:(NSObject<I_Task_Execute> *)executeTask;

+ (WSDownloadFileObject *)queryDownloadFileDataWithUrl:(NSString *)url;

@end
